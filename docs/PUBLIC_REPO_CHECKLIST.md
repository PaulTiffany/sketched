# Public repository launch checklist

## Completed locally

- [x] Git repository initialized.
- [x] MIT License names Paul Carver Tiffany III.
- [x] FabricPC checkout pinned by `verification/fabricpc_install_receipt.json`.
- [x] Dependency, build, Lean, and generated environments ignored.
- [x] Secret-pattern scan found only runtime API-key interfaces, not credentials.
- [x] Contribution and security guidance added.
- [x] README public-release language aligned with ADR-0004.

## Before first push

- [x] GitHub repository owner and name: `PaulTiffany/sketched`.
- [x] Prepare for a public repository launch.
- [x] Exclude local reviews, reproducible archives, and superseded rendered PDFs.
- [x] Audit public media: clear procedural audio and CC BY visual with attribution; exclude uncleared Edge-TTS MP4 narration pending replacement.
- [x] Run `npm test`, `npm run build`, and `python verification/run_all.py` (umbrella runner reports Windows sandbox-only subprocess/temp findings; direct app gates and both Lean builds pass).
- [ ] Create an intentional initial commit and inspect its file list.
- [x] Configure `origin` for `PaulTiffany/sketched` locally.
- [ ] Confirm/create the GitHub repository, push `main`, and enable GitHub secret scanning.
- [ ] Add a private vulnerability-reporting contact to the GitHub Security page.
