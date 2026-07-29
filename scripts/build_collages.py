#!/usr/bin/env python3
"""Build collage thumbnails from every figure used inside a tutorial.

Each tutorial gets two derived images:
  /images/collages/<slug>-card.jpg      16:10, used by the homepage grid/list cards
  /images/collages/<slug>-featured.jpg  4:3, used by the homepage featured side panel

Each figure is first trimmed of its surrounding white margin, then cover-fitted
into a cell so the board stays visually dense instead of mostly whitespace.

Usage: python3 scripts/build_collages.py [--check]
"""

from __future__ import annotations

import argparse
import pathlib
import re
import sys

from PIL import Image, ImageOps

ROOT = pathlib.Path(__file__).resolve().parent.parent
TUTORIALS = ROOT / "_tutorials"
OUT_DIR = ROOT / "images" / "collages"
DATA_FILE = ROOT / "_data" / "collages.yml"

BOARD = (248, 250, 252)   # #f8fafc
CELL_BG = (255, 255, 255)
LINE = (226, 232, 240)    # --sky-border
GAP = 4
TRIM_TOL = 246   # pixels brighter than this count as page margin

CARD_SIZE = (900, 563)      # 16:10
FEATURED_SIZE = (1040, 780)  # 4:3 side panel

IMG_RE = re.compile(r'(?:src="|!\[[^\]]*\]\()(/images/[^")\s]+)')
FM_IMG_RE = re.compile(r'^\s*(?:thumbnail|og_image):\s*"?(/images/[^"\s]+)"?', re.M)


def figures_for(md_path: pathlib.Path) -> list[pathlib.Path]:
    text = md_path.read_text()
    body = text.split("---", 2)[-1]
    front = text.split("---", 2)[1] if text.count("---") >= 2 else ""

    urls: list[str] = []
    for u in IMG_RE.findall(body):
        if u not in urls:
            urls.append(u)
    for u in FM_IMG_RE.findall(front):
        if u not in urls:
            urls.append(u)

    paths = []
    for u in urls:
        p = ROOT / u.lstrip("/")
        if p.exists():
            paths.append(p)
    return paths


def trim_margin(img: Image.Image) -> Image.Image:
    """Drop the near-white page margin that most paper figures carry."""
    mask = img.convert("L").point(lambda v: 0 if v >= TRIM_TOL else 255)
    bbox = mask.getbbox()
    if not bbox:
        return img
    pad = 4
    left = max(0, bbox[0] - pad)
    top = max(0, bbox[1] - pad)
    right = min(img.width, bbox[2] + pad)
    bottom = min(img.height, bbox[3] + pad)
    if right - left < 40 or bottom - top < 40:
        return img
    return img.crop((left, top, right, bottom))


def fit(img: Image.Image, box: tuple[int, int]) -> Image.Image:
    cell = Image.new("RGB", box, CELL_BG)
    filled = ImageOps.fit(trim_margin(img), box, Image.LANCZOS, centering=(0.5, 0.35))
    cell.paste(filled, (0, 0))
    # hairline border
    px = cell.load()
    for x in range(box[0]):
        px[x, 0] = LINE
        px[x, box[1] - 1] = LINE
    for y in range(box[1]):
        px[0, y] = LINE
        px[box[0] - 1, y] = LINE
    return cell


def layout_card(figs: list[Image.Image], size: tuple[int, int]) -> Image.Image:
    """Hero cell on the left, stacked companions on the right."""
    w, h = size
    board = Image.new("RGB", size, BOARD)
    left_w = int(w * 0.58) - GAP // 2
    right_w = w - left_w - GAP
    board.paste(fit(figs[0], (left_w, h)), (0, 0))

    rest = figs[1:4] or figs[:1]
    n = len(rest)
    cell_h = (h - GAP * (n - 1)) // n
    y = 0
    for i, f in enumerate(rest):
        this_h = h - y if i == n - 1 else cell_h
        board.paste(fit(f, (right_w, this_h)), (left_w + GAP, y))
        y += this_h + GAP
    return board


def layout_featured(figs: list[Image.Image], size: tuple[int, int]) -> Image.Image:
    """Even board of figures shown beside the featured copy."""
    w, h = size
    board = Image.new("RGB", size, BOARD)
    cols = 2 if len(figs) >= 2 else 1
    rows = 2 if len(figs) >= 4 else 1
    cell_w = (w - GAP * (cols - 1)) // cols
    cell_h = (h - GAP * (rows - 1)) // rows
    i = 0
    for r in range(rows):
        for c in range(cols):
            if i >= len(figs):
                break
            x = c * (cell_w + GAP)
            y = r * (cell_h + GAP)
            this_w = w - x if c == cols - 1 else cell_w
            this_h = h - y if r == rows - 1 else cell_h
            board.paste(fit(figs[i], (this_w, this_h)), (x, y))
            i += 1
    return board


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true",
                    help="fail if any collage is missing or stale")
    args = ap.parse_args()

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    DATA_FILE.parent.mkdir(parents=True, exist_ok=True)

    entries = []
    stale = []

    for md in sorted(TUTORIALS.glob("*.md")):
        slug = md.stem
        figs_paths = figures_for(md)
        if len(figs_paths) < 2:
            print(f"skip {slug}: needs at least 2 figures, found {len(figs_paths)}")
            continue

        newest = max(p.stat().st_mtime for p in figs_paths + [md])
        card_out = OUT_DIR / f"{slug}-card.jpg"
        feat_out = OUT_DIR / f"{slug}-featured.jpg"

        needs = [o for o in (card_out, feat_out)
                 if not o.exists() or o.stat().st_mtime < newest]
        if needs and args.check:
            stale.extend(str(o.relative_to(ROOT)) for o in needs)
        elif needs:
            figs = [Image.open(p).convert("RGB") for p in figs_paths]
            layout_card(figs, CARD_SIZE).save(card_out, quality=86, optimize=True,
                                              progressive=True)
            layout_featured(figs, FEATURED_SIZE).save(feat_out, quality=86,
                                                      optimize=True, progressive=True)
            print(f"built {slug}: {len(figs)} figures "
                  f"-> {card_out.name}, {feat_out.name}")

        entries.append((slug, len(figs_paths)))

    if args.check and stale:
        print("FAIL: stale or missing collages: " + ", ".join(stale))
        return 1

    lines = ["# Generated by scripts/build_collages.py — do not edit by hand.\n"]
    for slug, count in entries:
        lines.append(f"{slug}:\n")
        lines.append(f"  card: /images/collages/{slug}-card.jpg\n")
        lines.append(f"  featured: /images/collages/{slug}-featured.jpg\n")
        lines.append(f"  figure_count: {count}\n")
    DATA_FILE.write_text("".join(lines))
    print(f"wrote {DATA_FILE.relative_to(ROOT)} ({len(entries)} tutorials)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
