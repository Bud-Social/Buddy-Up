#!/usr/bin/env python3
"""Automatically remove a solid logo background via edge flood-fill.

Strategy:
  1. Estimate the background colour from the image border.
  2. Build a per-pixel distance map from that colour.
  3. Pick a split threshold automatically (Otsu) so only the connected
     background region is removed and subtle design elements (glow rings,
     gradients, anti-aliasing) are preserved.
  4. Flood-fill from the borders with that threshold, set those pixels to
     transparent, then softly blur the alpha edge so the logo blends in.
"""

import os
import sys
from collections import deque

import numpy as np
from PIL import Image, ImageFilter


def bg_color(rgb):
    border = np.concatenate([rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]], axis=0)
    return np.median(border, axis=0).astype(np.float64)


def distance_map(rgb, bg):
    diff = rgb.astype(np.float64) - bg
    return np.sqrt((diff ** 2).sum(axis=2))


def otsu_threshold(dist):
    dist = dist.astype(np.float64)
    dmin, dmax = dist.min(), dist.max()
    if dmax - dmin < 1e-6:
        return dmin + 1.0
    bins = 256
    hist, edges = np.histogram(dist, bins=bins, range=(dmin, dmax))
    centers = (edges[:-1] + edges[1:]) / 2.0
    total = hist.sum()
    sum_all = (hist * centers).sum()
    sum_b, w_b = 0.0, 0.0
    best_t, best_var = 0.0, -1.0
    for i in range(bins):
        w_b += hist[i]
        if w_b == 0:
            continue
        w_f = total - w_b
        if w_f == 0:
            break
        sum_b += hist[i] * centers[i]
        m_b = sum_b / w_b
        m_f = (sum_all - sum_b) / w_f
        var = w_b * w_f * (m_b - m_f) ** 2
        if var > best_var:
            best_var = var
            best_t = centers[i]
    return float(best_t)


def flood_fill_mask(dist, tol):
    h, w = dist.shape
    visited = np.zeros((h, w), dtype=bool)
    dq = deque()
    for y in range(h):
        dq.append((y, 0))
        dq.append((y, w - 1))
    for x in range(w):
        dq.append((0, x))
        dq.append((h - 1, x))
    while dq:
        y, x = dq.popleft()
        if visited[y, x] or dist[y, x] > tol:
            continue
        visited[y, x] = True
        for ny, nx in ((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)):
            if 0 <= ny < h and 0 <= nx < w and not visited[ny, nx] and dist[ny, nx] <= tol:
                dq.append((ny, nx))
    return visited


def process(path_in, path_out, tolerance=None, blur_radius=1.5):
    im = Image.open(path_in).convert('RGBA')
    rgb = np.asarray(im.convert('RGB')).astype(np.float64)
    bg = bg_color(rgb)
    dist = distance_map(rgb, bg)
    tol = tolerance if tolerance is not None else otsu_threshold(dist)
    mask = flood_fill_mask(dist, tol)

    alpha = np.where(mask, 0, 255).astype(np.uint8)
    out = im.copy()
    a = np.asarray(out).copy()
    a[:, :, 3] = alpha
    out = Image.fromarray(a, 'RGBA')

    if blur_radius > 0:
        # blur only the alpha channel for a soft, blended edge
        alpha_img = Image.fromarray(alpha, 'L').filter(
            ImageFilter.GaussianBlur(blur_radius)
        )
        a[:, :, 3] = np.asarray(alpha_img)
        # keep the core art fully opaque (protects against blur softening)
        core = np.asarray(
            Image.fromarray(alpha, 'L').filter(ImageFilter.MaxFilter(7))
        )
        a[core >= 255, 3] = 255
        out = Image.fromarray(a, 'RGBA')

    out.save(path_out, 'PNG')

    total = a.shape[0] * a.shape[1]
    full_trans = int((a[:, :, 3] == 0).sum())
    soft = int(((a[:, :, 3] > 0) & (a[:, :, 3] < 255)).sum())
    print(
        f"{os.path.basename(path_in)}: bg=({int(bg[0])},{int(bg[1])},{int(bg[2])}) "
        f"otsu_tol={tol:.1f} removed={full_trans/total*100:.1f}% soft={soft} "
        f"corner_alpha={int(a[2, 2, 3])}"
    )


def main():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    outdir = sys.argv[1] if len(sys.argv) > 1 else os.path.join(repo_root, "frontend", "public")
    os.makedirs(outdir, exist_ok=True)
    src = os.path.join(repo_root, "new logos")
    mapping = [
        ("Ambient Theme logo.png", "favicon-ambient.png"),
        ("Dark Theme Logo.png", "favicon-dark.png"),
        ("High Contrast Theme Logo.png", "favicon-high-contrast.png"),
        ("Light Theme Logo.png", "favicon-light.png"),
    ]
    for src_name, out_name in mapping:
        process(os.path.join(src, src_name), os.path.join(outdir, out_name))


if __name__ == '__main__':
    main()
