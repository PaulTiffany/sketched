"""Build Vimeo-ready Matt/Ellie lesson videos from offline narration receipts."""
from __future__ import annotations

import hashlib
import json
import subprocess
import sys
import wave
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
NARRATION = HERE / "rendered" / "manifest.json"
OUTPUT = HERE / "videos"
PUBLIC_RECEIPT = ROOT / "verification" / "offline_video_receipt.json"


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def duration(path: Path) -> float:
    with wave.open(str(path), "rb") as stream:
        return stream.getnframes() / stream.getframerate()


def stamp(seconds: float) -> str:
    millis = round(seconds * 1000)
    hours, millis = divmod(millis, 3_600_000)
    minutes, millis = divmod(millis, 60_000)
    secs, millis = divmod(millis, 1000)
    return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"


def captions(segments: list[dict], target: Path, gap: float = 0.28) -> None:
    cursor = 0.0
    blocks = []
    for index, segment in enumerate(segments, 1):
        wav = ROOT / segment["file"]
        length = duration(wav)
        blocks.append(
            f"{index}\n{stamp(cursor)} --> {stamp(cursor + length)}\n"
            f"{segment['speaker']}: {segment['text']}\n"
        )
        cursor += length + gap
    target.write_text("\n".join(blocks), encoding="utf-8")


def main() -> int:
    if not NARRATION.is_file():
        raise FileNotFoundError("render narration first: npm run voice:render")
    source = json.loads(NARRATION.read_text(encoding="utf-8"))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    videos = []
    for lesson in source["lessons"]:
        goal = lesson["goal"]
        wav = ROOT / lesson["file"]
        srt = OUTPUT / f"{goal}.srt"
        mp4 = OUTPUT / f"{goal}.mp4"
        poster = OUTPUT / f"{goal}.jpg"
        captions(lesson["segments"], srt)
        title = goal.replace("-", " ").title()
        graph = (
            "[1:a]showwaves=s=1080x260:mode=line:colors=68d5ff|f0b95b:rate=30,"
            "format=rgba[w];"
            "[0:v][w]overlay=(W-w)/2:300[v0];"
            f"[v0]drawtext=fontfile='C\\:/Windows/Fonts/arial.ttf':text='SKETCHED  /  {title}':"
            "fontcolor=white:fontsize=42:x=(w-text_w)/2:y=110,"
            "drawtext=fontfile='C\\:/Windows/Fonts/arial.ttf':text='MATT + ELLIE  /  VERIFIED OFFLINE NARRATION':"
            "fontcolor=9fb3c8:fontsize=22:x=(w-text_w)/2:y=175[v]"
        )
        command = [
            "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
            "-f", "lavfi", "-i", "color=c=0x09111f:s=1280x720:r=30",
            "-i", str(wav), "-i", str(srt),
            "-filter_complex", graph,
            "-map", "[v]", "-map", "1:a:0", "-map", "2:0",
            "-c:v", "libx264", "-preset", "medium", "-crf", "20",
            "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "192k",
            "-c:s", "mov_text", "-metadata:s:s:0", "language=eng",
            "-movflags", "+faststart", "-shortest", str(mp4),
        ]
        subprocess.run(command, check=True)
        subprocess.run([
            "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
            "-ss", "1", "-i", str(mp4), "-frames:v", "1", "-q:v", "2", str(poster),
        ], check=True)
        videos.append({
            "goal": goal,
            "title": title,
            "mp4": mp4.relative_to(ROOT).as_posix(),
            "mp4_sha256": sha256(mp4),
            "subtitles": srt.relative_to(ROOT).as_posix(),
            "subtitles_sha256": sha256(srt),
            "poster": poster.relative_to(ROOT).as_posix(),
            "poster_sha256": sha256(poster),
            "duration_seconds": round(duration(wav), 3),
            "video": "H.264 1280x720 30fps yuv420p CRF 20",
            "audio": "AAC 192 kbps from pinned offline Piper WAV",
            "captions": "embedded mov_text plus sidecar SRT",
        })
    receipt = {
        "schema": "sketched.offline-video.v1",
        "compiler": "selfcompile/voices/video.py",
        "narration_manifest_sha256": sha256(NARRATION),
        "distribution_target": "Vimeo-compatible MP4",
        "videos": videos,
    }
    (OUTPUT / "manifest.json").write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    PUBLIC_RECEIPT.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    print(f"built {len(videos)} Vimeo-ready videos -> {OUTPUT}")
    print(f"public receipt -> {PUBLIC_RECEIPT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())