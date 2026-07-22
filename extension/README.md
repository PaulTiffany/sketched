# Z0 OmegaClaw

OmegaClaw is the desktop-browser form of Z0 SURF. The browser remains the browser; Omega runs in Chrome or Edge's side panel beside the real active tab.

## Install the development build

1. Download or clone this repository.
2. Open `chrome://extensions` in Chrome or `edge://extensions` in Edge.
3. Enable **Developer mode**.
4. Choose **Load unpacked**.
5. Select the repository's `extension` directory.
6. Pin **Z0 OmegaClaw** and click it while viewing a page.
7. Open **SETUP**, add an OpenRouter key, and leave the model as `openrouter/free` or provide another zero-cost compatible model.

## Current capabilities

- Opens beside the actual active browser tab through the Side Panel API.
- Reads the live DOM of ordinary web pages after the user invokes the extension.
- Uses a readable fallback for arXiv papers and other HTTP(S) surfaces that cannot be injected.
- Sends the current selection and page/paper text to Omega.
- Requires Omega to return an exact evidence phrase with each grounded answer.
- Highlights that evidence amber in injectable HTML pages.
- Marks the user's current text selection cyan.
- Stores the OpenRouter key only in extension-local storage and sends inference directly to OpenRouter.

## Browser boundaries

Chrome's built-in PDF viewer, browser settings pages, extension stores, and some privileged pages do not permit content-script injection. OmegaClaw can still read supported online PDFs through the reader channel, but exact in-document highlighting inside Chrome's native PDF viewer requires a later dedicated PDF viewer or PDF.js extension page.

Local `file://` reading is disabled by Chrome until the user enables **Allow access to file URLs** on the extension's details page. Local PDF highlighting has the same native-viewer limitation described above.

## Privacy model

The extension starts with `activeTab`, not permanent access to browsing history. Clicking OmegaClaw grants temporary access to the current tab. OpenRouter receives only the text packaged for an explicit question. The extension does not continuously monitor navigation or send pages in the background.
