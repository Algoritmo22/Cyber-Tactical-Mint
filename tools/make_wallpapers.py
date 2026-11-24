#!/usr/bin/env python3
"""Genera los fondos de pantalla de Cyber-Tactical-Mint a partir de las paletas.

Uso:   python3 tools/make_wallpapers.py [--size 3840x2160]
Requiere: Pillow y numpy   (pip install pillow numpy)

Cada archivo palettes/<nombre>.sh produce wallpapers/<nombre>.jpg y una
miniatura en docs/img/wallpaper-<nombre>.jpg.
"""
from __future__ import annotations

import argparse
import math
import random
import re
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent


def load_palette(path: Path) -> dict[str, str]:
    data = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        m = re.match(r'^(P_[A-Z_]+)="([^"]*)"', line.strip())
        if m:
            data[m.group(1)] = m.group(2)
    return data


def rgb(hexstr: str, alpha: int | None = None):
    r, g, b = (int(hexstr[i:i + 2], 16) for i in (0, 2, 4))
    return (r, g, b) if alpha is None else (r, g, b, alpha)


def vertical_gradient(w: int, h: int, top: tuple, bottom: tuple) -> Image.Image:
    t = np.linspace(0, 1, h)[:, None, None]
    top_a, bot_a = np.array(top, float), np.array(bottom, float)
    arr = (top_a * (1 - t) + bot_a * t) * np.ones((1, w, 1))
    return Image.fromarray(arr.astype(np.uint8), "RGB")


def glow_composite(base: Image.Image, layer: Image.Image, radii=(28, 10)) -> Image.Image:
    """Suma un halo difuminado de `layer` sobre `base` y luego la capa nítida."""
    out = base.convert("RGBA")
    for r in radii:
        out = Image.alpha_composite(out, layer.filter(ImageFilter.GaussianBlur(r)))
    return Image.alpha_composite(out, layer)


def make(palette: dict[str, str], w: int, h: int, seed: int = 7) -> Image.Image:
    rnd = random.Random(seed)
    bg, bg_alt = rgb(palette["P_BG"]), rgb(palette["P_BG_ALT"])
    prim, sec = palette["P_PRIMARY"], palette["P_SECONDARY"]
    acc, muted = palette["P_ACCENT"], palette["P_MUTED"]

    horizon = int(h * 0.60)
    cx = w // 2
    img = vertical_gradient(w, h, bg_alt, bg).convert("RGBA")

    # Resplandor del horizonte
    yy, xx = np.mgrid[0:h, 0:w]
    d = np.sqrt(((xx - cx) / (w * 0.55)) ** 2 + ((yy - horizon) / (h * 0.30)) ** 2)
    glow = np.clip(1 - d, 0, 1) ** 2.2
    tint = np.array(rgb(sec), float)
    base = np.array(img.convert("RGB"), float)
    base += glow[..., None] * tint * 0.22
    img = Image.fromarray(np.clip(base, 0, 255).astype(np.uint8), "RGB").convert("RGBA")

    # Estrellas / partículas en el cielo
    stars = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    sd = ImageDraw.Draw(stars)
    for _ in range(420):
        x, y = rnd.randrange(w), rnd.randrange(int(horizon * 0.95))
        s = rnd.choice((1, 1, 2, 2, 3))
        a = rnd.randrange(40, 170)
        sd.ellipse((x, y, x + s, y + s), fill=rgb(muted, a))
    img = Image.alpha_composite(img, stars)

    # Rejilla en perspectiva
    grid = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    gd = ImageDraw.Draw(grid)
    lw = max(2, w // 1400)
    n_h = 22
    for k in range(1, n_h + 1):
        y = horizon + (h - horizon) * (k / n_h) ** 2.3
        a = int(60 + 150 * (k / n_h))
        gd.line([(0, y), (w, y)], fill=rgb(prim, a), width=lw)
    spread = w * 0.11
    for i in range(-30, 31):
        x_bottom = cx + i * spread
        gd.line([(cx + i * 6, horizon), (x_bottom, h)], fill=rgb(prim, 150), width=lw)
    # Desvanece la rejilla cerca del horizonte
    fade = np.clip((yy - horizon) / (h * 0.16), 0, 1)
    ga = np.array(grid)
    ga[..., 3] = (ga[..., 3] * fade).astype(np.uint8)
    img = glow_composite(img, Image.fromarray(ga, "RGBA"), radii=(18,))

    # Línea del horizonte
    hl = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(hl).line([(0, horizon), (w, horizon)], fill=rgb(sec, 230), width=lw * 2)
    img = glow_composite(img, hl, radii=(30, 8))

    # Anillos tipo radar sobre el horizonte
    rings = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    rd = ImageDraw.Draw(rings)
    for i, r in enumerate((h * 0.16, h * 0.26, h * 0.37)):
        box = (cx - r, horizon - r, cx + r, horizon + r)
        rd.arc(box, 180, 360, fill=rgb(sec, 200 - i * 45), width=lw * 2)
        for deg in range(180, 361, 6):
            a = math.radians(deg)
            r0, r1 = r - (14 if deg % 30 == 0 else 7), r
            rd.line([(cx + r0 * math.cos(a), horizon + r0 * math.sin(a)),
                     (cx + r1 * math.cos(a), horizon + r1 * math.sin(a))],
                    fill=rgb(sec, 170), width=lw)
    # Línea de barrido
    ang = math.radians(235)
    rr = h * 0.37
    rd.line([(cx, horizon), (cx + rr * math.cos(ang), horizon + rr * math.sin(ang))],
            fill=rgb(acc, 230), width=lw * 2)
    rd.ellipse((cx - 9, horizon - 9, cx + 9, horizon + 9), fill=rgb(acc, 255))
    img = glow_composite(img, rings, radii=(22, 6))

    # Marcos HUD en las esquinas
    hud = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    hd = ImageDraw.Draw(hud)
    m, L, t = int(w * 0.025), int(w * 0.05), max(3, w // 900)
    for (x0, y0, sx, sy) in ((m, m, 1, 1), (w - m, m, -1, 1), (m, h - m, 1, -1), (w - m, h - m, -1, -1)):
        hd.line([(x0, y0), (x0 + sx * L, y0)], fill=rgb(prim, 230), width=t)
        hd.line([(x0, y0), (x0, y0 + sy * L)], fill=rgb(prim, 230), width=t)
    img = glow_composite(img, hud, radii=(10,))

    # Texto discreto
    txt = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    td = ImageDraw.Draw(txt)
    font = None
    for cand in ("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf",
                 "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"):
        if Path(cand).exists():
            font = ImageFont.truetype(cand, max(14, w // 110))
            break
    font = font or ImageFont.load_default()
    td.text((m + L + 24, h - m - L // 2), "CYBER-TACTICAL // MINT", font=font, fill=rgb(prim, 200))
    td.text((m + L + 24, h - m - L // 2 + max(18, w // 95)),
            f"PALETTE: {palette['P_NAME'].upper()}", font=font, fill=rgb(muted, 220))
    img = Image.alpha_composite(img, txt)

    # Líneas de escaneo + viñeta
    arr = np.array(img.convert("RGB"), float)
    arr[::4, :, :] *= 0.93
    vign = 1 - 0.45 * np.clip(np.sqrt(((xx - cx) / (w * 0.75)) ** 2 + ((yy - h / 2) / (h * 0.8)) ** 2), 0, 1) ** 2
    arr *= vign[..., None]
    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGB")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--size", default="3840x2160")
    args = ap.parse_args()
    w, h = (int(v) for v in args.size.lower().split("x"))

    (ROOT / "wallpapers").mkdir(exist_ok=True)
    (ROOT / "docs" / "img").mkdir(parents=True, exist_ok=True)
    for pf in sorted((ROOT / "palettes").glob("*.sh")):
        pal = load_palette(pf)
        name = pal["P_NAME"]
        img = make(pal, w, h)
        out = ROOT / "wallpapers" / f"{name}.jpg"
        img.save(out, "JPEG", quality=90, optimize=True, progressive=True)
        thumb = img.resize((960, int(960 * h / w)), Image.LANCZOS)
        thumb.save(ROOT / "docs" / "img" / f"wallpaper-{name}.jpg", "JPEG", quality=85, optimize=True)
        print(f"✔ {out.relative_to(ROOT)}  ({out.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    main()
