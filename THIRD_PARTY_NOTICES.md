# Third-party notices and asset review

Sketched's source code is released under the repository's MIT License. This file records external dependencies and generated artifacts that require their own provenance rather than silently treating everything as original source.

## Dependencies

JavaScript packages are declared in `package.json` and pinned in `package-lock.json`. Their source is not vendored; each package remains under its upstream license. Lean dependencies are fetched through Lake and are not committed under `.lake/`.

## FabricPC

FabricPC is not vendored into this repository. The ignored local checkout is pinned by `verification/fabricpc_install_receipt.json`; the bridge cites the upstream project. FabricPC is MIT-licensed, copyright 2026 Matthew Behrend.

## Public media

The visual and sound-bed inputs have been audited. Attribution and the exact clearance matrix live in `ASSET_ATTRIBUTION.md`. The ambient bed is procedural; the one external photograph is CC BY 2.0 and is attributed there. Narration was generated through Microsoft Edge's online TTS endpoint using `edge-tts`, not a documented paid Azure TTS resource. Because the applicable terms do not clearly grant redistribution of that output, `public/media/*.mp4` is excluded from the public repository. Certificates, subtitles, posters, and provenance remain.

## Review artifacts and archives

`.review/`, `book.zip`, and `packets/*.zip` are excluded as local previews or reproducible archives. The v14 and v15 TeX sources remain for historical and verification use, while their generated PDFs are excluded; v16 is the current human-readable rendered paper.

## Piper offline narration

The Matt/Ellie self-compile path uses the Piper 1.4.2 engine as an unvendored
local build tool. The pinned Cori and Kristin voice models use public-domain
LibriVox source recordings and are distributed from the MIT-licensed Piper
voice repository. See `selfcompile/voices/voices.json` for exact hashes and
model cards. This pipeline does not retroactively clear the older Edge-TTS MP4
files; those remain withheld until regenerated.