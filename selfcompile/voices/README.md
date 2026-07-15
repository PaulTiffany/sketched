# Offline Matt and Ellie narration

The self-compiled semantic program is rendered locally with Piper 1.4.2.
Matt uses `en_GB-cori-medium`; Ellie uses `en_US-kristin-medium`. Both model
cards identify their source recordings as public-domain LibriVox material. The
Piper voice repository is MIT-licensed. Model identity is enforced by SHA-256.

The engine environment, model weights, and rendered WAV files are reproducible
local artifacts and are ignored by Git. The checked-in renderer and
`voices.json` are the public provenance contract.

From the repository root:

```powershell
python -m venv .venv-voice
.\.venv-voice\Scripts\python.exe -m pip install https://github.com/OHF-Voice/piper1-gpl/releases/download/v1.4.2/piper_tts-1.4.2-cp39-abi3-win_amd64.whl
.\.venv-voice\Scripts\python.exe -m piper.download_voices --data-dir selfcompile\voices\models en_GB-cori-medium en_US-kristin-medium
.\.venv-voice\Scripts\python.exe selfcompile\voices\render.py
```

Outputs land under `selfcompile/voices/rendered/`. Its `manifest.json` binds
every segment to its speaker, semantic act, exact text, and audio hash.
## Vimeo-ready videos

After narration is current, build H.264/AAC MP4s with embedded captions,
sidecar SRT files, and posters:

```powershell
npm run video:render
```

Outputs land under `selfcompile/voices/videos/`; the checked-in
`verification/offline_video_receipt.json` records every artifact hash.