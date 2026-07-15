# Asset attribution and redistribution status

## Cleared for repository distribution

- **Free Speech Wall photograph** — Daniel Rothamel, via Wikimedia Commons, licensed [CC BY 2.0](https://creativecommons.org/licenses/by/2.0/). Source: <https://commons.wikimedia.org/wiki/File:Free_Speech_Wall.jpg>. Used in `at_the_breakpoints`; cropped, composited, animated, and overlaid with text and color treatments. No endorsement by the photographer is implied.
- **Sketched book-tour images** — screenshots of this repository's locally rendered application, created for the project.
- **Bounded Observer visuals** — generated project graphics and excerpts from Paul Carver Tiffany III's Principia Symbolica source material.
- **Ambient sound bed and chimes** — procedurally synthesized from sine waves by `orbit_review`; no recorded or sampled audio assets are used.

## Not included in the public repository

The MP4 narration tracks were synthesized with the MIT-licensed `edge-tts` client using Microsoft Edge's online TTS endpoint and prebuilt voices `en-US-JennyNeural` and `en-US-AndrewNeural`. The client license covers its software, not Microsoft's service output. Microsoft's published Product Terms expressly grant commercial output use for paid-tier Azure TTS, but these files were not generated through a documented paid Azure TTS resource. Because an equivalent redistribution grant for the Edge endpoint was not established, the MP4s are excluded by `.gitignore` pending replacement with locally synthesized speech or regeneration through a service tier whose output license is recorded.

## Offline Matt and Ellie narration

The replacement narration pipeline uses Piper 1.4.2 locally. Matt is rendered
with `en_GB-cori-medium`; Ellie uses `en_US-kristin-medium`. Their model cards
identify the source recordings as public-domain LibriVox material, and the
Piper voice-model repository is MIT-licensed. Exact model hashes and source
links live in `selfcompile/voices/voices.json`; generated lesson hashes live in
`verification/offline_voice_receipt.json`. The large models and WAV files are
reproducible local artifacts and are not vendored.