#!/usr/bin/env bash
# Add your own wallpaper (a lion, say) to a Golden Apple variant and switch to it.
#
#   tools/add-wallpaper.sh ~/Pictures/lion.jpg              # adds it to Golden Apple (dark)
#   tools/add-wallpaper.sh ~/Pictures/lion.jpg golden-apple-light
#
# It goes into ~/.config/omarchy/backgrounds/<theme>/, which is where Omarchy keeps
# the backgrounds you add yourself — they survive re-running ./install.sh and they
# show up in `omarchy theme bg next` alongside the generated ones. Pass --repo to
# put it in this repo's own backgrounds/ instead, so it ships with the theme.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

repo=0
args=()
for a in "$@"; do
  case "$a" in
    --repo) repo=1 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) args+=("$a") ;;
  esac
done
file="${args[0]:?usage: add-wallpaper.sh <image> [golden-apple|golden-apple-light] [--repo]}"
theme="${args[1]:-golden-apple}"
[ -f "$file" ] || { echo "no such file: $file" >&2; exit 1; }
case "$theme" in golden-apple|golden-apple-light) ;; *) echo "theme must be golden-apple or golden-apple-light" >&2; exit 2 ;; esac

name=$(basename "$file")
if [ "$repo" -eq 1 ]; then
  dest="$here/backgrounds"
  [ "$theme" = golden-apple ] || dest="$here/themes/$theme/backgrounds"
else
  dest="$HOME/.config/omarchy/backgrounds/$theme"
fi
mkdir -p "$dest"
cp "$file" "$dest/$name"
echo "added $dest/$name"

if command -v omarchy >/dev/null 2>&1 && [ "$repo" -eq 0 ]; then
  current=$(omarchy theme current 2>/dev/null | head -1)
  if [ "${current,,}" = "${theme//-/ }" ]; then
    omarchy theme bg set "$dest/$name" >/dev/null 2>&1 && echo "set as the current background"
  else
    echo "switch to it with: omarchy theme set $theme && omarchy theme bg set '$dest/$name'"
  fi
fi

cat <<'EOF'

Tip: a photographic wallpaper is where the glass earns its keep — the blur has
something to work with, which a flat gradient never gives it.
EOF
