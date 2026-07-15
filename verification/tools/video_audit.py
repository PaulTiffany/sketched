"""Audit Vimeo-ready offline lesson video receipts and optional local renders."""
from __future__ import annotations

import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RECEIPT = ROOT / "verification" / "offline_video_receipt.json"


def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def main() -> int:
    findings: list[str] = []
    receipt = json.loads(RECEIPT.read_text(encoding="utf-8"))
    if receipt.get("schema") != "sketched.offline-video.v1":
        findings.append("VIDEO_SCHEMA: invalid receipt schema")
    videos = receipt.get("videos", [])
    if len(videos) != 5 or len({v.get("goal") for v in videos}) != 5:
        findings.append("VIDEO_SET: expected five unique videos")
    for video in videos:
        goal = video.get("goal", "?")
        for key, hash_key in (("mp4", "mp4_sha256"), ("subtitles", "subtitles_sha256"), ("poster", "poster_sha256")):
            expected = video.get(hash_key, "")
            if not re.fullmatch(r"[0-9a-f]{64}", expected):
                findings.append(f"VIDEO_HASH {goal}/{key}: invalid SHA-256")
                continue
            path = ROOT / video.get(key, "")
            if path.is_file() and digest(path) != expected:
                findings.append(f"VIDEO_DRIFT {goal}/{key}: artifact hash changed")
        mp4 = ROOT / video.get("mp4", "")
        if mp4.is_file():
            probe = subprocess.run([
                "ffprobe", "-v", "error", "-show_entries", "stream=codec_type,codec_name,width,height",
                "-of", "json", str(mp4)
            ], capture_output=True, text=True, check=True)
            streams = json.loads(probe.stdout)["streams"]
            codecs = {(s["codec_type"], s["codec_name"]) for s in streams}
            if not {("video", "h264"), ("audio", "aac"), ("subtitle", "mov_text")} <= codecs:
                findings.append(f"VIDEO_STREAMS {goal}: expected H.264, AAC, and mov_text")
            picture = next((s for s in streams if s["codec_type"] == "video"), {})
            if (picture.get("width"), picture.get("height")) != (1280, 720):
                findings.append(f"VIDEO_FRAME {goal}: expected 1280x720")
    for finding in findings:
        print(f"[{finding}]")
    print(f"{len(findings)} findings; {len(videos)} Vimeo-ready videos")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())