from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path
from statistics import median

import numpy as np
from PIL import Image, ImageDraw


BREEDS = [
    "mixed",
    "shiba",
    "chihuahua",
    "toy_poodle",
    "golden_retriever",
    "husky",
    "pomeranian",
]

EXPRESSIONS = [
    "excited_greeting",
    "attention_seeking",
    "happy_relaxed",
    "warning_alert",
    "anxious_whine",
    "sleepy",
    "restless_energy",
    "bored",
    "uncertain",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Mechanically crop a 7x9 dog expression sheet into app assets.",
    )
    parser.add_argument("input", type=Path, help="Path to the source sheet image.")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("assets/expression_icons"),
        help="Directory to write the 63 cropped assets into.",
    )
    parser.add_argument(
        "--debug-image",
        type=Path,
        default=Path("tmp_expression_debug.png"),
        help="Optional debug overlay image path.",
    )
    parser.add_argument(
        "--metadata-json",
        type=Path,
        default=Path("tmp_expression_debug.json"),
        help="Optional metadata output path.",
    )
    return parser.parse_args()


def sample_background_colors(rgb: np.ndarray, border: int = 64) -> np.ndarray:
    h, w, _ = rgb.shape
    border = min(border, h // 4, w // 4)
    samples = np.concatenate(
        [
            rgb[:border, :, :].reshape(-1, 3),
            rgb[h - border :, :, :].reshape(-1, 3),
            rgb[:, :border, :].reshape(-1, 3),
            rgb[:, w - border :, :].reshape(-1, 3),
        ],
        axis=0,
    )
    quantized = (samples // 8).astype(np.int16)
    counts = Counter(map(tuple, quantized))
    top_bins = [np.array(key) for key, _ in counts.most_common(2)]
    colors = []
    for bin_key in top_bins:
        matches = np.all(quantized == bin_key, axis=1)
        colors.append(samples[matches].mean(axis=0))
    return np.array(colors, dtype=np.float32)


def build_foreground_mask(rgb: np.ndarray, background_colors: np.ndarray) -> np.ndarray:
    distances = ((rgb[:, :, None, :].astype(np.float32) - background_colors[None, None, :, :]) ** 2).sum(axis=3)
    min_distance = distances.min(axis=2)
    return min_distance > 120.0


def moving_average(values: np.ndarray, radius: int) -> np.ndarray:
    window = radius * 2 + 1
    kernel = np.ones(window, dtype=np.float32) / float(window)
    return np.convolve(values.astype(np.float32), kernel, mode="same")


def contiguous_runs(mask: np.ndarray) -> list[tuple[int, int]]:
    runs: list[tuple[int, int]] = []
    start: int | None = None
    for index, is_active in enumerate(mask.tolist()):
        if is_active and start is None:
            start = index
        elif not is_active and start is not None:
            runs.append((start, index - 1))
            start = None
    if start is not None:
        runs.append((start, len(mask) - 1))
    return runs


def merge_close_runs(runs: list[tuple[int, int]], max_gap: int = 3) -> list[tuple[int, int]]:
    merged: list[list[int]] = []
    for start, end in runs:
        if not merged or start - merged[-1][1] > max_gap:
            merged.append([start, end])
        else:
            merged[-1][1] = end
    return [(start, end) for start, end in merged]


def detect_row_cuts(mask: np.ndarray) -> list[int]:
    projection = mask.sum(axis=1)
    smooth = moving_average(projection, radius=3)
    low_rows = smooth <= 2.5
    gap_runs = merge_close_runs(contiguous_runs(low_rows))
    if len(gap_runs) < 8:
        raise RuntimeError(f"Expected at least 8 horizontal background runs, found {len(gap_runs)}.")

    foreground_rows = np.where(projection > 5)[0]
    top = int(foreground_rows[0])
    bottom = int(foreground_rows[-1])
    internal_runs = gap_runs[1:-1]
    row_cuts = [top] + [int(round((start + end) / 2)) for start, end in internal_runs] + [bottom]
    if len(row_cuts) != 8:
        raise RuntimeError(f"Expected 8 horizontal cuts, found {len(row_cuts)}: {row_cuts}")
    return row_cuts


def detect_col_cuts(mask: np.ndarray, row_cuts: list[int]) -> list[int]:
    full_projection = mask.sum(axis=0)
    foreground_columns = np.where(full_projection > 5)[0]
    left = int(foreground_columns[0])
    right = int(foreground_columns[-1])

    internal_cuts: list[int] = []
    for index in range(1, len(EXPRESSIONS)):
        expected = left + (right - left) * index / len(EXPRESSIONS)
        search_radius = int((right - left) / (len(EXPRESSIONS) * 2.7))
        picks: list[int] = []
        for row_index in range(len(BREEDS)):
            band = mask[row_cuts[row_index] : row_cuts[row_index + 1], :]
            projection = band.sum(axis=0)
            smooth = moving_average(projection, radius=4)
            low = max(0, int(expected - search_radius))
            high = min(mask.shape[1] - 1, int(expected + search_radius))
            picks.append(low + int(np.argmin(smooth[low : high + 1])))
        internal_cuts.append(int(round(median(picks))))

    col_cuts = [left] + internal_cuts + [right]
    if len(col_cuts) != 10:
        raise RuntimeError(f"Expected 10 vertical cuts, found {len(col_cuts)}: {col_cuts}")
    return col_cuts


def write_debug_artifacts(image: Image.Image, row_cuts: list[int], col_cuts: list[int], debug_image: Path, metadata_json: Path) -> None:
    overlay = image.convert("RGBA")
    draw = ImageDraw.Draw(overlay)
    for x in col_cuts:
        draw.line((x, 0, x, overlay.height), fill=(0, 180, 255, 255), width=2)
    for y in row_cuts:
        draw.line((0, y, overlay.width, y), fill=(255, 80, 80, 255), width=2)
    debug_image.parent.mkdir(parents=True, exist_ok=True)
    overlay.save(debug_image)

    metadata = {
        "row_cuts": row_cuts,
        "col_cuts": col_cuts,
        "rows": BREEDS,
        "columns": EXPRESSIONS,
    }
    metadata_json.parent.mkdir(parents=True, exist_ok=True)
    metadata_json.write_text(json.dumps(metadata, indent=2, ensure_ascii=False), encoding="utf-8")


def crop_sheet(source_path: Path, output_dir: Path, debug_image: Path, metadata_json: Path) -> None:
    image = Image.open(source_path).convert("RGBA")
    rgb = np.array(image.convert("RGB"))
    background_colors = sample_background_colors(rgb)
    mask = build_foreground_mask(rgb, background_colors)

    row_cuts = detect_row_cuts(mask)
    col_cuts = detect_col_cuts(mask, row_cuts)

    output_dir.mkdir(parents=True, exist_ok=True)
    for row_index, breed in enumerate(BREEDS):
        top = row_cuts[row_index]
        bottom = row_cuts[row_index + 1]
        for col_index, expression in enumerate(EXPRESSIONS):
            left = col_cuts[col_index]
            right = col_cuts[col_index + 1]
            crop = image.crop((left, top, right, bottom))
            crop.save(output_dir / f"{breed}_{expression}.png")

    write_debug_artifacts(image, row_cuts, col_cuts, debug_image, metadata_json)


def main() -> None:
    args = parse_args()
    crop_sheet(args.input, args.output_dir, args.debug_image, args.metadata_json)


if __name__ == "__main__":
    main()
