#!/usr/bin/env bash
# Generate the Golden Apple mesh-gradient wallpapers.
#
#   tools/make-wallpapers.sh [WIDTHxHEIGHT]      # default 2560x1440
#
# Each wallpaper is a handful of soft colour blobs over a base, built small,
# blurred, then scaled up — the same construction as the gradient wallpapers
# iOS ships. A little noise is added at the end: a smooth gradient in 8-bit
# banks into visible bands otherwise.
#
# Colours come from the theme's own palette, so the wallpapers and the UI agree.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
size="${1:-2560x1440}"
w=${size%x*}
h=${size#*x}
command -v magick >/dev/null || { echo "needs ImageMagick (magick)" >&2; exit 1; }

# Blobs are placed on a 100x100 grid: "COLOR CX CY RADIUS" (radius in grid units).
# Low-res canvas the blobs are drawn on; it is blurred and scaled up afterwards.
LOW_W=320
LOW_H=180

blobs() {   # base_color compose_mode out "blob..."  -> writes the wallpaper to $out
  local base=$1 mode=$2 out=$3; shift 3
  local args=() spec color cx cy r d x y geo far
  for spec in "$@"; do
    read -r color cx cy r <<<"$spec"
    d=$(python3 -c "print(int($r / 100 * $LOW_W * 2))")
    x=$(python3 -c "print(int($cx / 100 * $LOW_W - $d / 2))")
    y=$(python3 -c "print(int($cy / 100 * $LOW_H - $d / 2))")
    # A blob usually hangs off an edge, so the offset can be negative: it has to
    # be written as "-118+82", never "+-118+82", or ImageMagick silently misreads it.
    geo=$(printf '%+d%+d' "$x" "$y")
    far=black; [ "$mode" = Multiply ] && far=white
    args+=( \( -size "${d}x${d}" radial-gradient:"$color"-"$far" -alpha off \) -geometry "$geo" -compose "$mode" -composite )
  done
  # Built small and blurred, then scaled up: that is what makes the falloff smooth
  # rather than banded. JPEG's own dithering keeps the sky free of stair-steps and
  # the file in the tens of kilobytes; the same gradient as PNG is megabytes.
  # +repage matters: each blob leaves its offset on the canvas's page geometry, and
  # -extent honours that page — without it the whole wallpaper comes out as background.
  magick -size "${LOW_W}x${LOW_H}" "xc:$base" "${args[@]}" \
    +repage \
    -blur 0x28 \
    -resize "${w}x${h}^" -gravity center -background "$base" -extent "${w}x${h}" \
    -quality 92 "$out"
  echo "  $(basename "$(dirname "$out")")/$(basename "$out")  $(du -h "$out" | cut -f1)"
}

dark="$here/backgrounds"
light="$here/themes/golden-apple-light/backgrounds"
mkdir -p "$dark" "$light"

echo "Golden Apple (dark) — ${size}"
# Amber: the default. Deep gold rising out of warm black.
blobs "#0d0b07" Screen "$dark/1-amber.jpg" \
  "#8a6320 18 78 55" "#c79a3a 52 96 45" "#5a3f14 86 70 42" "#3a2a10 68 30 38"
# Ember: gold with a red-brown heart, for a lion-coloured desktop.
blobs "#0b0805" Screen "$dark/2-ember.jpg" \
  "#7a3f1a 22 84 52" "#c98a2e 62 96 46" "#4a2a12 86 40 44" "#2e1d0c 40 34 40"
# Leaf: gold against the olive end of the palette.
blobs "#0b0a06" Screen "$dark/3-savanna.jpg" \
  "#6b6a22 20 80 50" "#c7a33a 64 94 46" "#3d3a16 88 34 42" "#241f0e 44 40 38"
# Bronze: nearly flat, for wallpapers that should not compete with the glass.
blobs "#0d0b07" Screen "$dark/4-bronze.jpg" \
  "#221b10 30 70 60" "#2e2415 75 35 50" "#c79a3a 92 96 20"

echo "Golden Apple Light — ${size}"
# Champagne: cream washed with light gold.
blobs "#fffdf7" Multiply "$light/1-champagne.jpg" \
  "#f2e3bf 22 78 55" "#fbf1d8 60 92 48" "#eee0c4 85 30 44"
# Honey: warmer, towards amber.
blobs "#fffdf7" Multiply "$light/2-honey.jpg" \
  "#f7e0b4 24 74 52" "#fae9c9 64 90 46" "#f1ddc6 84 26 44"
# Linen: the quietest of the four.
blobs "#fffdf7" Multiply "$light/3-linen.jpg" \
  "#f3eee0 26 76 52" "#f8f2e6 66 90 44" "#efe8d6 86 28 42"
# Parchment: almost flat, warm paper with a hint of gold.
blobs "#faf6ec" Multiply "$light/4-parchment.jpg" \
  "#f2ecdb 30 70 60" "#efe6cf 78 34 50"
