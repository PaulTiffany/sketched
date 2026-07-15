"""Audit the pinned offline Matt/Ellie narration contract and optional artifacts."""
from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONFIG = ROOT / "selfcompile" / "voices" / "voices.json"
RECEIPT = ROOT / "verification" / "offline_voice_receipt.json"
MODELS = ROOT / "selfcompile" / "voices" / "models"


def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def main() -> int:
    findings: list[str] = []
    config = json.loads(CONFIG.read_text(encoding="utf-8"))
    receipt = json.loads(RECEIPT.read_text(encoding="utf-8"))
    if config.get("schema") != "sketched.offline-voices.v1":
        findings.append("VOICE_SCHEMA: invalid voice configuration schema")
    if receipt.get("schema") != "sketched.offline-narration.v1":
        findings.append("VOICE_RECEIPT_SCHEMA: invalid narration receipt schema")
    if config.get("engine", {}).get("version") != "1.4.2":
        findings.append("VOICE_ENGINE: Piper must remain pinned to 1.4.2")
    voices = config.get("voices", {})
    if set(voices) != {"Matt", "Ellie"}:
        findings.append("VOICE_CAST: expected exactly Matt and Ellie")
    for speaker, voice in voices.items():
        if voice.get("dataset_license") != "public domain":
            findings.append(f"VOICE_LICENSE {speaker}: dataset is not public domain")
        if voice.get("model_repository_license") != "MIT":
            findings.append(f"VOICE_MODEL_LICENSE {speaker}: expected MIT")
        expected = voice.get("sha256", "")
        if not re.fullmatch(r"[0-9a-f]{64}", expected):
            findings.append(f"VOICE_HASH {speaker}: invalid SHA-256")
        model = MODELS / voice.get("model", "")
        if model.is_file() and digest(model) != expected:
            findings.append(f"VOICE_MODEL_DRIFT {speaker}: {model.name}")
    if receipt.get("voices") != voices:
        findings.append("VOICE_RECEIPT_DRIFT: receipt voices differ from configuration")
    lessons = receipt.get("lessons", [])
    if len(lessons) != 5 or len({row.get("goal") for row in lessons}) != 5:
        findings.append("VOICE_LESSONS: expected five unique compiled lessons")
    for row in lessons:
        if not re.fullmatch(r"[0-9a-f]{64}", row.get("sha256", "")):
            findings.append(f"VOICE_AUDIO_HASH {row.get('goal')}: invalid SHA-256")
        audio = ROOT / row.get("file", "")
        if audio.is_file() and digest(audio) != row.get("sha256"):
            findings.append(f"VOICE_AUDIO_DRIFT {row.get('goal')}: rendered WAV changed")
    for finding in findings:
        print(f"[{finding}]")
    print(f"{len(findings)} findings; {len(voices)} pinned voices; {len(lessons)} rendered lessons")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())