# Dev-time scripts

Developer utilities that are **not** part of the running app or the Docker image.

## `extract_portraits.py`

Regenerates the source character portraits (`app/assets/images/illustrations/<faction>/*.png`)
from the official Carnevale faction PDFs. It pulls the embedded image object out of each PDF,
fixes Adobe-inverted CMYK, converts to sRGB, and applies the soft-mask as alpha — producing the
figure on a transparent background at native resolution.

Only needed when adding/refreshing art; the backoffice card renderer then frames these portraits
into cards (see `app/views/backoffice/profiles/card.html.erb`) and publishes them to
`public/cards` via Render-to-catalog.

**Requirements** (host tools, not bundled): Python 3, `pdfimages` (poppler), `magick` (ImageMagick).

```
python3 script/extract_portraits.py <pdf-or-dir> [output-dir] [--icc [profile.icc]]
```
