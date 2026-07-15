"""Render the verified Matt/Ellie semantic program with pinned offline Piper voices."""
from __future__ import annotations

import hashlib
import json
import subprocess
import sys
import wave
from pathlib import Path

HERE = Path(__file__).resolve().parent
SELF_COMPILE = HERE.parent
ROOT = SELF_COMPILE.parent
sys.path.insert(0, str(SELF_COMPILE))

import bookdata
import ellie

CONFIG = HERE / "voices.json"
MODELS = HERE / "models"
OUTPUT = HERE / "rendered"
PUBLIC_RECEIPT = ROOT / "verification" / "offline_voice_receipt.json"
GOALS = json.loads((SELF_COMPILE / "goals.json").read_text(encoding="utf-8"))["goals"]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def render_line(python: Path, voice: dict, text: str, output: Path) -> None:
    model = MODELS / voice["model"]
    config = model.with_suffix(model.suffix + ".json")
    if not model.is_file() or not config.is_file():
        raise FileNotFoundError(
            f"missing {model.name}; run the download command in selfcompile/voices/README.md"
        )
    actual = sha256(model)
    if actual != voice["sha256"]:
        raise RuntimeError(f"hash mismatch for {model.name}: {actual}")
    command = [
        str(python), "-m", "piper", "-m", str(model), "-c", str(config),
        "-f", str(output), "--length-scale", str(voice["length_scale"]),
        "--sentence-silence", "0.18",
    ]
    subprocess.run(command, input=text, text=True, check=True)


def concatenate(parts: list[Path], output: Path, silence_seconds: float = 0.28) -> None:
    if not parts:
        return
    with wave.open(str(parts[0]), "rb") as first:
        params = first.getparams()
        frames = [first.readframes(first.getnframes())]
    silence = b"\0" * int(params.framerate * silence_seconds) * params.sampwidth * params.nchannels
    for part in parts[1:]:
        with wave.open(str(part), "rb") as stream:
            if (stream.getnchannels(), stream.getsampwidth(), stream.getframerate()) != (
                params.nchannels, params.sampwidth, params.framerate
            ):
                raise RuntimeError(f"incompatible WAV parameters: {part}")
            frames.extend((silence, stream.readframes(stream.getnframes())))
    with wave.open(str(output), "wb") as target:
        target.setparams(params)
        for frame in frames:
            target.writeframes(frame)


def main() -> int:
    config = json.loads(CONFIG.read_text(encoding="utf-8"))
    python = ROOT / ".venv-voice" / "Scripts" / "python.exe"
    if not python.is_file():
        raise FileNotFoundError(".venv-voice missing; follow selfcompile/voices/README.md")
    OUTPUT.mkdir(parents=True, exist_ok=True)
    results = [ellie.run_goal(goal, bookdata.chapters()) for goal in GOALS]
    receipt = {
        "schema": "sketched.offline-narration.v1",
        "engine": config["engine"],
        "voices": config["voices"],
        "lessons": [],
    }
    for result in results:
        if not result["nodes"]:
            continue
        goal_id = result["goal"]["id"]
        lesson_dir = OUTPUT / goal_id
        lesson_dir.mkdir(parents=True, exist_ok=True)
        parts: list[Path] = []
        segments = []
        for index, node in enumerate(result["nodes"], 1):
            speaker = node["speaker"]
            voice = config["voices"][speaker]
            part = lesson_dir / f"{index:02d}-{speaker.lower()}-{node['act']}.wav"
            render_line(python, voice, node["speech"], part)
            parts.append(part)
            segments.append({
                "speaker": speaker,
                "act": node["act"],
                "text": node["speech"],
                "file": part.relative_to(ROOT).as_posix(),
                "sha256": sha256(part),
            })
        combined = OUTPUT / f"{goal_id}.wav"
        concatenate(parts, combined)
        receipt["lessons"].append({
            "goal": goal_id,
            "file": combined.relative_to(ROOT).as_posix(),
            "sha256": sha256(combined),
            "segments": segments,
        })
    manifest = OUTPUT / "manifest.json"
    manifest.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    public = dict(receipt)
    public["lessons"] = [
        {"goal": lesson["goal"], "file": lesson["file"],
         "sha256": lesson["sha256"], "segments": len(lesson["segments"])}
        for lesson in receipt["lessons"]
    ]
    PUBLIC_RECEIPT.write_text(json.dumps(public, indent=2) + "\n", encoding="utf-8")
    print(f"rendered {len(receipt['lessons'])} lessons -> {OUTPUT}")
    print(f"manifest -> {manifest}")
    print(f"public receipt -> {PUBLIC_RECEIPT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())