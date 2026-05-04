from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from pathlib import Path

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

# The new green-screen sheet provided by the user is arranged in this order.
SOURCE_COLUMNS = [
    "excited_greeting",
    "attention_seeking",
    "warning_alert",
    "anxious_whine",
    "sleepy",
    "restless_energy",
    "happy_relaxed",
    "bored",
    "uncertain",
]


@dataclass(frozen=True)
class CropBounds:
    left: int
    top: int
    right: int
    bottom: int


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Crop a 7x9 dog expression sheet and remove green-screen backgrounds.",
    )
    parser.add_argument("input", help="Path to the source sheet image, directory, or glob pattern.")
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
    parser.add_argument(
        "--canvas-size",
        type=int,
        default=192,
        help="Square canvas size for each transparent icon.",
    )
    parser.add_argument(
        "--cell-inset",
        type=int,
        default=8,
        help="Inset applied inside each detected cell before chroma-key extraction.",
    )
    parser.add_argument(
        "--content-padding",
        type=int,
        default=10,
        help="Padding between extracted content and the square canvas edge.",
    )
    parser.add_argument(
        "--source-mode",
        choices=["auto", "sheet", "numbered-icons"],
        default="auto",
        help="How to interpret the input. 'numbered-icons' expects 63 files like dogsEmotion001.png.",
    )
    return parser.parse_args()


def build_green_mask(rgb: np.ndarray) -> np.ndarray:
    red = rgb[:, :, 0].astype(np.int16)
    green = rgb[:, :, 1].astype(np.int16)
    blue = rgb[:, :, 2].astype(np.int16)
    max_other = np.maximum(red, blue)
    return (green >= 110) & ((green - max_other) >= 28)


def compute_grid_bounds(image: Image.Image) -> tuple[list[int], list[int]]:
    width, height = image.size
    col_bounds = [round(width * i / len(SOURCE_COLUMNS)) for i in range(len(SOURCE_COLUMNS) + 1)]
    row_bounds = [round(height * i / len(BREEDS)) for i in range(len(BREEDS) + 1)]
    return col_bounds, row_bounds


def extract_content_bbox(alpha: np.ndarray) -> CropBounds | None:
    ys, xs = np.where(alpha > 0)
    if len(xs) == 0 or len(ys) == 0:
        return None
    return CropBounds(
        left=int(xs.min()),
        top=int(ys.min()),
        right=int(xs.max()) + 1,
        bottom=int(ys.max()) + 1,
    )


def remove_green_background(cell: Image.Image) -> Image.Image:
    rgba = np.array(cell.convert("RGBA"))
    rgb = rgba[:, :, :3]
    alpha = rgba[:, :, 3]
    green_mask = build_green_mask(rgb)
    alpha[green_mask] = 0
    rgba[:, :, 3] = alpha
    return Image.fromarray(rgba, mode="RGBA")


def fit_on_square_canvas(content: Image.Image, canvas_size: int, padding: int) -> Image.Image:
    target = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    inner = canvas_size - padding * 2
    scale = min(inner / content.width, inner / content.height)
    resized = content.resize(
        (
            max(1, int(round(content.width * scale))),
            max(1, int(round(content.height * scale))),
        ),
        Image.Resampling.LANCZOS,
    )
    x = (canvas_size - resized.width) // 2
    y = (canvas_size - resized.height) // 2
    target.alpha_composite(resized, (x, y))
    return target


def write_debug_artifacts(
    image: Image.Image,
    row_bounds: list[int],
    col_bounds: list[int],
    debug_image: Path,
    metadata_json: Path,
) -> None:
    overlay = image.convert("RGBA")
    draw = ImageDraw.Draw(overlay)
    for x in col_bounds:
        draw.line((x, 0, x, overlay.height), fill=(255, 255, 255, 220), width=2)
    for y in row_bounds:
        draw.line((0, y, overlay.width, y), fill=(255, 255, 255, 220), width=2)
    debug_image.parent.mkdir(parents=True, exist_ok=True)
    overlay.save(debug_image)

    metadata = {
        "row_bounds": row_bounds,
        "col_bounds": col_bounds,
        "rows": BREEDS,
        "columns": SOURCE_COLUMNS,
    }
    metadata_json.parent.mkdir(parents=True, exist_ok=True)
    metadata_json.write_text(json.dumps(metadata, indent=2, ensure_ascii=False), encoding="utf-8")


def write_icon_debug_artifacts(
    files: list[Path],
    output_dir: Path,
    metadata_json: Path,
) -> None:
    metadata = {
        "source_files": [str(file) for file in files],
        "rows": BREEDS,
        "columns": SOURCE_COLUMNS,
        "output_dir": str(output_dir),
    }
    metadata_json.parent.mkdir(parents=True, exist_ok=True)
    metadata_json.write_text(json.dumps(metadata, indent=2, ensure_ascii=False), encoding="utf-8")


def natural_key(path: Path) -> tuple[int, str]:
    match = re.search(r"(\d+)$", path.stem)
    return (int(match.group(1)) if match else 0, path.name)


def resolve_input_files(input_value: str) -> list[Path]:
    if "*" in input_value or "?" in input_value:
        path = Path(input_value)
        base = path.parent if str(path.parent) not in ("", ".") else Path(".")
        return sorted(base.glob(path.name), key=natural_key)
    path = Path(input_value)
    if path.is_dir():
        return sorted(path.glob("*.png"), key=natural_key)
    if path.is_file():
        return [path]
    return []


def crop_sheet(
    source_path: Path,
    output_dir: Path,
    debug_image: Path,
    metadata_json: Path,
    canvas_size: int,
    cell_inset: int,
    content_padding: int,
) -> None:
    image = Image.open(source_path).convert("RGBA")
    col_bounds, row_bounds = compute_grid_bounds(image)
    output_dir.mkdir(parents=True, exist_ok=True)

    for row_index, breed in enumerate(BREEDS):
        cell_top = row_bounds[row_index]
        cell_bottom = row_bounds[row_index + 1]
        for col_index, expression in enumerate(SOURCE_COLUMNS):
            cell_left = col_bounds[col_index]
            cell_right = col_bounds[col_index + 1]
            inset_bounds = CropBounds(
                left=min(cell_left + cell_inset, cell_right - 1),
                top=min(cell_top + cell_inset, cell_bottom - 1),
                right=max(cell_left + cell_inset + 1, cell_right - cell_inset),
                bottom=max(cell_top + cell_inset + 1, cell_bottom - cell_inset),
            )
            cell = image.crop(
                (
                    inset_bounds.left,
                    inset_bounds.top,
                    inset_bounds.right,
                    inset_bounds.bottom,
                ),
            )
            keyed = remove_green_background(cell)
            bbox = extract_content_bbox(np.array(keyed)[:, :, 3])
            if bbox is None:
                final_icon = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
            else:
                content = keyed.crop((bbox.left, bbox.top, bbox.right, bbox.bottom))
                final_icon = fit_on_square_canvas(content, canvas_size, content_padding)
            final_icon.save(output_dir / f"{breed}_{expression}.png")

    write_debug_artifacts(image, row_bounds, col_bounds, debug_image, metadata_json)


def convert_numbered_icons(
    source_files: list[Path],
    output_dir: Path,
    metadata_json: Path,
    canvas_size: int,
    content_padding: int,
) -> None:
    expected_count = len(BREEDS) * len(SOURCE_COLUMNS)
    if len(source_files) < expected_count:
        raise RuntimeError(f"Expected at least {expected_count} source icons, found {len(source_files)}.")

    output_dir.mkdir(parents=True, exist_ok=True)
    ordered_files = source_files[:expected_count]
    for row_index, breed in enumerate(BREEDS):
        for col_index, expression in enumerate(SOURCE_COLUMNS):
            file_index = row_index * len(SOURCE_COLUMNS) + col_index
            source = ordered_files[file_index]
            keyed = remove_green_background(Image.open(source).convert("RGBA"))
            bbox = extract_content_bbox(np.array(keyed)[:, :, 3])
            if bbox is None:
                final_icon = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
            else:
                content = keyed.crop((bbox.left, bbox.top, bbox.right, bbox.bottom))
                final_icon = fit_on_square_canvas(content, canvas_size, content_padding)
            final_icon.save(output_dir / f"{breed}_{expression}.png")

    write_icon_debug_artifacts(ordered_files, output_dir, metadata_json)


def main() -> None:
    args = parse_args()
    source_mode = args.source_mode
    input_value = str(args.input)
    resolved_files = resolve_input_files(input_value)
    if source_mode == "auto":
        if len(resolved_files) >= len(BREEDS) * len(SOURCE_COLUMNS):
            source_mode = "numbered-icons"
        else:
            source_mode = "sheet"

    if source_mode == "numbered-icons":
        convert_numbered_icons(
            source_files=resolved_files,
            output_dir=args.output_dir,
            metadata_json=args.metadata_json,
            canvas_size=args.canvas_size,
            content_padding=args.content_padding,
        )
        return

    crop_sheet(
        source_path=Path(input_value),
        output_dir=args.output_dir,
        debug_image=args.debug_image,
        metadata_json=args.metadata_json,
        canvas_size=args.canvas_size,
        cell_inset=args.cell_inset,
        content_padding=args.content_padding,
    )


if __name__ == "__main__":
    main()
