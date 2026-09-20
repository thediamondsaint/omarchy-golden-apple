#!/usr/bin/env bash
# Generate the iOS-style mesh-gradient wallpapers.
#
#   tools/make-wallpapers.sh [WIDTHxHEIGHT]      # default 2560x1440
#
# Each wallpaper is a handful of soft colour blobs over a base, built small,
# blurred, then scaled up — the same construction as the gradient wallpapers
# iOS ships. A little noise is added at the end: a smooth gradient in 8-bit
# banks into visible bands otherwise.
#
# Colours are Apple's system colours, so the wallpapers and the palette agree.
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

dark="$here/themes/ios/backgrounds"
light="$here/themes/ios-light/backgrounds"
mkdir -p "$dark" "$light"

echo "iOS (dark) — ${size}"
# Deep space blue: the default. Blue and cyan rising out of black.
blobs "#000000" Screen "$dark/1-horizon.jpg" \
  "#0a3f8f 18 78 55" "#0a84ff 52 96 45" "#1b3a6b 86 70 42" "#102a4d 68 30 38"
# Aurora: iOS 17's purple/teal wash.
blobs "#000000" Screen "$dark/2-aurora.jpg" \
  "#5e2b97 22 26 48" "#0a84ff 70 62 46" "#1f7a6b 88 18 34" "#2a1a4d 45 80 46"
# Sunset: the warm end of the system palette.
blobs "#050208" Screen "$dark/3-sunset.jpg" \
  "#8a2b4d 20 80 52" "#b4531a 60 92 44" "#3b1d6b 82 24 46" "#5c1f3f 40 40 38"
# Graphite: near-black for people who want the icons to do the talking.
blobs "#000000" Screen "$dark/4-graphite.jpg" \
  "#1c1c1e 30 70 60" "#2c2c2e 75 35 50" "#0a84ff 90 95 22"

echo "iOS Light — ${size}"
# Daybreak: the white-to-blue wash of the iOS Settings background.
blobs "#ffffff" Multiply "$light/1-daybreak.jpg" \
  "#cfe3ff 22 78 55" "#e7f0ff 60 92 48" "#dbe7fb 85 30 44"
# Peach: warm systemPink/systemOrange at low strength.
blobs "#ffffff" Multiply "$light/2-peach.jpg" \
  "#ffd9d3 24 74 52" "#ffe6cc 64 90 46" "#f3ddf0 84 26 44"
# Mint: systemGreen/systemTeal.
blobs "#ffffff" Multiply "$light/3-mint.jpg" \
  "#cdeede 26 76 52" "#d8f0f5 66 90 44" "#e6f2e0 86 28 42"
# Paper: almost flat, systemGroupedBackground with a hint of blue.
blobs "#f7f7fa" Multiply "$light/4-paper.jpg" \
  "#eceef5 30 70 60" "#e6ebf7 78 34 50"
