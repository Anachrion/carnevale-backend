#!/usr/bin/env python3
"""
Extract raw character portraits from Carnevale faction PDFs.

Replicates the manual ImageMagick pipeline that gave the clean result:
  - pull the embedded character image object straight out of the PDF (pdfimages)
  - if it is stored as Adobe-inverted CMYK, negate it; convert to sRGB
  - apply the soft-mask as the alpha channel
Output is the figure on a transparent background, at native resolution.

No Pillow / PyMuPDF — only `pdfimages` (poppler) and `magick` (ImageMagick),
which is what produced the good extraction by hand.

Usage:
    python3 extract_portraits.py <pdf-or-dir> [output-dir] [--icc [profile.icc]]

    <pdf-or-dir>  a single .pdf, or a directory (every *.pdf inside is processed)
    [output-dir]  where PNGs go (default: ./images)
    --icc         convert CMYK via an ICC profile instead of the naive math
                  transform, matching what Preview/Acrobat display. Defaults
                  to macOS "Generic CMYK Profile.icc"; pass a path to override.
"""

import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

SRGB_ICC = "/System/Library/ColorSync/Profiles/sRGB Profile.icc"
DEFAULT_CMYK_ICC = "/System/Library/ColorSync/Profiles/Generic CMYK Profile.icc"


def run(cmd):
    return subprocess.run(cmd, check=True, capture_output=True, text=True)


def list_page_images(pdf, page):
    """Parse `pdfimages -list` for one page into row dicts."""
    out = run(["pdfimages", "-f", str(page), "-l", str(page), "-list", str(pdf)]).stdout
    rows = []
    for line in out.splitlines():
        parts = line.split()
        # data rows start with two integers: page num
        if len(parts) < 6 or not (parts[0].isdigit() and parts[1].isdigit()):
            continue
        rows.append(
            {
                "num": int(parts[1]),
                "type": parts[2],          # image | smask | stencil
                "width": int(parts[3]),
                "height": int(parts[4]),
                "color": parts[5],         # rgb | cmyk | gray | index
                "enc": parts[8],           # jpeg | image | png | ...
            }
        )
    return rows


def pick_characters(rows):
    """All portrait images on the page: rgb/cmyk, roughly square, 250-900px.

    Some cards show two figures stored as two separate images, so this
    returns every match (left-to-right in object order). The floor excludes
    the title banner (573x105) and icons (<=132px tall); the ceiling and the
    color filter exclude the page background and the gray damask."""
    chars = []
    for r in rows:
        if r["type"] != "image" or r["color"] not in ("rgb", "cmyk"):
            continue
        w, h = r["width"], r["height"]
        if not (180 <= w <= 900 and 180 <= h <= 900):
            continue
        if max(w, h) / min(w, h) > 2.0:
            continue
        chars.append(r)
    return chars


def pick_smask(rows, char):
    """Soft-mask sharing the portrait's dimensions (prefer the one right after)."""
    candidates = [
        r for r in rows
        if r["type"] == "smask" and r["width"] == char["width"] and r["height"] == char["height"]
    ]
    if not candidates:
        return None
    after = [r for r in candidates if r["num"] == char["num"] + 1]
    return after[0] if after else candidates[0]


def file_for(prefix, num):
    matches = sorted(prefix.parent.glob(f"{prefix.name}-{num:03d}.*"))
    return matches[0] if matches else None


def extract_page(pdf, page, tmp, out_stem, cmyk_icc=None):
    """Extract every portrait on the page. Returns the list of files written.

    out_stem is the path without extension; a single figure becomes
    "<stem>.png", multiple become "<stem>_a.png", "<stem>_b.png", ..."""
    rows = list_page_images(pdf, page)
    chars = pick_characters(rows)
    if not chars:
        return []

    prefix = tmp / "img"
    run(["pdfimages", "-all", "-f", str(page), "-l", str(page), str(pdf), str(prefix)])

    written = []
    for i, char in enumerate(chars):
        char_file = file_for(prefix, char["num"])
        if char_file is None:
            continue
        suffix = f"_{chr(ord('a') + i)}" if len(chars) > 1 else ""
        out_path = Path(f"{out_stem}{suffix}.png")

        smask = pick_smask(rows, char)
        smask_file = file_for(prefix, smask["num"]) if smask else None

        cmd = ["magick", str(char_file)]
        if char["color"] == "cmyk":
            if char["enc"] in ("jpeg", "jpx"):
                cmd.append("-negate")
            if cmyk_icc:
                cmd += ["-profile", cmyk_icc, "-profile", SRGB_ICC]
            else:
                cmd += ["-colorspace", "sRGB"]
        else:
            cmd += ["-colorspace", "sRGB"]
        if smask_file:
            cmd += ["(", str(smask_file), "-colorspace", "gray", ")",
                    "-alpha", "off", "-compose", "CopyOpacity", "-composite"]
        cmd.append(str(out_path))
        run(cmd)
        written.append(out_path)

    for f in prefix.parent.glob(f"{prefix.name}-*"):
        f.unlink(missing_ok=True)
    return written


def page_count(pdf):
    out = run(["pdfinfo", str(pdf)]).stdout
    m = re.search(r"^Pages:\s+(\d+)", out, re.MULTILINE)
    return int(m.group(1)) if m else 0


def process_pdf(pdf, out_dir, cmyk_icc=None):
    stem = re.sub(r"[^a-z0-9]+", "_", pdf.stem.lower()).strip("_")
    faction = re.sub(r"^the_", "", re.sub(r"_\d+$", "", stem))
    faction_dir = out_dir / faction
    faction_dir.mkdir(parents=True, exist_ok=True)
    total = page_count(pdf)
    print(f"\n{pdf.name}  ({total} pages)")
    ok = 0
    with tempfile.TemporaryDirectory() as t:
        tmp = Path(t)
        for page in range(1, total + 1):
            out_stem = faction_dir / f"p{page:02d}"
            try:
                files = extract_page(pdf, page, tmp, out_stem, cmyk_icc)
                if files:
                    ok += len(files)
                    print(f"  [OK]   p{page:02d} -> {', '.join(f.name for f in files)}")
            except subprocess.CalledProcessError as e:
                print(f"  [FAIL] p{page:02d}: {e.stderr.strip().splitlines()[-1:] or e}")
    print(f"  -> {ok} portraits")
    return ok


def main():
    parser = argparse.ArgumentParser(
        description="Extract Carnevale character portraits from faction PDFs.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("src", help="a single .pdf or a directory of PDFs")
    parser.add_argument("out_dir", nargs="?", default="images", help="output dir (default: ./images)")
    parser.add_argument(
        "--icc", nargs="?", const=DEFAULT_CMYK_ICC, default=None, metavar="PROFILE.icc",
        help="convert CMYK via an ICC profile (default: macOS Generic CMYK Profile)",
    )
    args = parser.parse_args()

    if args.icc and not Path(args.icc).exists():
        print(f"Error: CMYK profile not found: {args.icc}")
        sys.exit(1)

    src = Path(args.src).expanduser()
    out_dir = Path(args.out_dir).expanduser()
    out_dir.mkdir(parents=True, exist_ok=True)

    pdfs = sorted(src.glob("*.pdf")) if src.is_dir() else [src]
    if not pdfs:
        print(f"No PDFs found at {src}")
        sys.exit(1)

    total = sum(process_pdf(p, out_dir, args.icc) for p in pdfs)
    print(f"\nDone. {total} portraits in {out_dir}/  ({'ICC' if args.icc else 'naive'} CMYK conversion)")


if __name__ == "__main__":
    main()
