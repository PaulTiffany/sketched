import asyncio
import json
import os
import time
import uuid
from collections import defaultdict, deque
from dataclasses import dataclass
from typing import Any

from fastapi import FastAPI, Header, HTTPException, Request, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

ALLOWED_ORIGIN = os.getenv("Z0_ALLOWED_ORIGIN", "https://paultiffany.github.io")
ACCESS_TOKEN = os.getenv("Z0_ACCESS_TOKEN", "").strip()
WS_TOKEN = os.getenv("OMEGACLAW_WS_TOKEN", "").strip()
RATE_LIMIT = max(1, int(os.getenv("Z0_RATE_LIMIT_PER_HOUR", "12")))
TURN_TIMEOUT = max(30, int(os.getenv("Z0_TURN_TIMEOUT_SECONDS", "180")))

app = FastAPI(title="Z0 Real OmegaClaw Gateway", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=[ALLOWED_ORIGIN],
    allow_credentials=False,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)


class TurnRequest(BaseModel):
    instruction: str = Field(min_length=1, max_length=4000)
    surface: dict[str, Any] = Field(default_factory=dict)
    session_id: str = Field(default="", max_length=128)


@dataclass
class PendingTurn:
    request_id: str
    future: asyncio.Future
    created_at: float


agent: WebSocket | None = None
agent_lock = asyncio.Lock()
turn_lock = asyncio.Lock()
pending: PendingTurn | None = None
sequence = 0
results: dict[str, dict[str, Any]] = {}
rate_buckets: dict[str, deque[float]] = defaultdict(deque)


def _client_key(request: Request) -> str:
    forwarded = request.headers.get("x-forwarded-for", "")
    return (forwarded.split(",", 1)[0].strip() or (request.client.host if request.client else "unknown"))[:128]


def _authorize(value: str | None) -> None:
    if not ACCESS_TOKEN:
        return
    supplied = (value or "").removeprefix("Bearer ").strip()
    if supplied != ACCESS_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid Z0 access token")


def _rate_limit(key: str) -> None:
    now = time.time()
    bucket = rate_buckets[key]
    while bucket and bucket[0] < now - 3600:
        bucket.popleft()
    if len(bucket) >= RATE_LIMIT:
        raise HTTPException(status_code=429, detail="Public OmegaClaw turn limit reached")
    bucket.append(now)


def _surface_text(surface: dict[str, Any]) -> str:
    url = str(surface.get("url", ""))[:1000]
    title = str(surface.get("title", ""))[:500]
    page = str(surface.get("page", ""))[:40]
    selection = str(surface.get("selection", ""))[:5000]
    text = str(surface.get("text", ""))[:24000]
    return (
        f"SURFACE URL: {url}\n"
        f"SURFACE TITLE: {title}\n"
        f"PAGE: {page}\n"
        f"SELECTED TEXT:\n{selection or 'none'}\n\n"
        f"READABLE CONTEXT:\n{text or 'none'}"
    )


def _prompt(turn: TurnRequest) -> str:
    contract = (
        "Return exactly one compact JSON object with keys: reply, channel, operators, visual, sound. "
        "channel must be voice, notes, both, or silent. operators may use preserve, route, fracture, "
        "integrate, witness, exclude, return, differentiate, bind, release. visual is an array of sparse "
        "normalized 0..1 path, circle, arrow, or label instructions. Never use cyan; cyan belongs to the human. "
        "sound is an array of MIDI-like note events. Do not include markdown fences or commentary outside JSON."
    )
    return f"{turn.instruction}\n\n{_surface_text(turn.surface)}\n\nOUTPUT CONTRACT:\n{contract}"


@app.get("/health")
async def health() -> dict[str, Any]:
    return {
        "ok": True,
        "runtime": "asi-alliance/OmegaClaw-Core",
        "transport": "official websocket channel",
        "agent_connected": agent is not None,
        "busy": turn_lock.locked(),
        "public_profile": True,
    }


@app.post("/api/turn")
async def submit_turn(
    turn: TurnRequest,
    request: Request,
    authorization: str | None = Header(default=None),
) -> dict[str, Any]:
    _authorize(authorization)
    _rate_limit(_client_key(request))
    if agent is None:
        raise HTTPException(status_code=503, detail="OmegaClaw is waking or disconnected")
    request_id = uuid.uuid4().hex
    asyncio.create_task(_run_turn(request_id, turn))
    return {"request_id": request_id, "status": "queued"}


@app.get("/api/turn/{request_id}")
async def get_turn(
    request_id: str,
    authorization: str | None = Header(default=None),
) -> dict[str, Any]:
    _authorize(authorization)
    return results.get(request_id, {"request_id": request_id, "status": "pending"})


async def _run_turn(request_id: str, turn: TurnRequest) -> None:
    global pending, sequence
    async with turn_lock:
        if agent is None:
            results[request_id] = {"request_id": request_id, "status": "error", "error": "OmegaClaw disconnected"}
            return
        loop = asyncio.get_running_loop()
        future: asyncio.Future = loop.create_future()
        pending = PendingTurn(request_id=request_id, future=future, created_at=time.time())
        sequence += 1
        try:
            await agent.send_json({"type": "user_message", "seq": sequence, "text": _prompt(turn)})
            text = await asyncio.wait_for(future, timeout=TURN_TIMEOUT)
            results[request_id] = {"request_id": request_id, "status": "complete", "text": text}
        except Exception as exc:
            results[request_id] = {"request_id": request_id, "status": "error", "error": str(exc)}
        finally:
            pending = None
            cutoff = time.time() - 3600
            for key in list(results):
                if results[key].get("created_at", time.time()) < cutoff:
                    results.pop(key, None)


@app.websocket("/agent")
async def agent_channel(websocket: WebSocket) -> None:
    global agent
    if WS_TOKEN:
        supplied = websocket.headers.get("authorization", "").removeprefix("Bearer ").strip()
        if supplied != WS_TOKEN:
            await websocket.close(code=4401)
            return
    await websocket.accept()
    async with agent_lock:
        agent = websocket
        try:
            while True:
                frame = json.loads(await websocket.receive_text())
                frame_type = frame.get("type")
                if frame_type == "resume":
                    continue
                if frame_type == "agent_message":
                    client_seq = str(frame.get("client_seq", ""))
                    await websocket.send_json({"type": "ack", "seq": sequence, "client_seq": client_seq})
                    if pending and not pending.future.done():
                        pending.future.set_result(str(frame.get("text", "")))
                elif frame_type not in {"ack"}:
                    await websocket.send_json({"type": "error", "code": "unsupported", "message": "Unsupported frame"})
        except WebSocketDisconnect:
            pass
        finally:
            if agent is websocket:
                agent = None
            if pending and not pending.future.done():
                pending.future.set_exception(RuntimeError("OmegaClaw disconnected"))
