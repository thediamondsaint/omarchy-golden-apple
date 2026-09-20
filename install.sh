#!/usr/bin/env bash
# Install the iOS theme for Omarchy.
#
#   ./install.sh              install both variants and switch to iOS (dark)
#   ./install.sh --light      ... and switch to iOS Light instead
#   ./install.sh --no-apply   install them but keep your current theme
#   ./install.sh --wallpapers regenerate the wallpapers at this display's resolution first
#   ./install.sh --check      say what would happen, change nothing
#
# The theme is COPIED into ~/.config/omarchy/themes/. That is deliberate:
# `omarchy theme install <git-url>` clones instead, and Omarchy refuses to load
# Lua from a cloned theme — which is exactly where the window shape, the glass
# and the animations live. A copied theme is yours, so all of it applies.
set -uo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
themes_dir="$HOME/.config/omarchy/themes"
state="$HOME/.local/state/omarchy-ios-theme"
variants=(ios ios-light)
apply=ios
do_apply=1
check=0
regen=0

for arg in "$@"; do
  case "$arg" in
    --light) apply=ios-light ;;
    --dark) apply=ios ;;
    --no-apply) do_apply=0 ;;
    --wallpapers) regen=1 ;;
    --check) check=1 ;;
    -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf '%s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

have omarchy || die "omarchy is not on PATH — this is a theme for Omarchy (https://omarchy.org)"
version=$(omarchy version 2>/dev/null | head -1)
case "$version" in
  3.*|2.*|1.*) die "this theme is for Omarchy 4: it styles the Quickshell bar and uses Lua Hyprland config. This machine runs Omarchy $version." ;;
esac
[ -d "$HOME/.config/omarchy" ] || die "no ~/.config/omarchy here; is this an Omarchy install?"

echo "Omarchy $version"
if [ "$check" -eq 1 ]; then
  for v in "${variants[@]}"; do
    if [ -d "$themes_dir/$v" ]; then
      echo "  would replace $themes_dir/$v (a backup copy is kept)"
    else
      echo "  would install $themes_dir/$v"
    fi
    printf '    %s\n' "$(ls "$here/themes/$v" | tr '\n' ' ')"
  done
  [ "$do_apply" -eq 1 ] && echo "  would then run: omarchy theme set $apply"
  exit 0
fi

if [ "$regen" -eq 1 ]; then
  if have magick; then
    res=$(hyprctl monitors -j 2>/dev/null | python3 -c '
import json,sys
try:
    m = json.load(sys.stdin)
    w = max(int(x["width"] / (x.get("scale") or 1)) for x in m)
    h = max(int(x["height"] / (x.get("scale") or 1)) for x in m)
    print("%dx%d" % (w, h))
except Exception:
    print("")' 2>/dev/null)
    [ -n "$res" ] || res=2560x1440
    echo "regenerating wallpapers at $res..."
    "$here/tools/make-wallpapers.sh" "$res" || warn "wallpaper generation failed; the ones in the repo are used instead"
  else
    warn "ImageMagick (magick) is not installed, keeping the wallpapers from the repo"
  fi
fi

mkdir -p "$themes_dir" "$state"
for v in "${variants[@]}"; do
  target="$themes_dir/$v"
  if [ -e "$target" ]; then
    backup="$target.bak.$(date +%s)"
    mv "$target" "$backup" || die "could not move $target aside"
    echo "kept your existing $v theme as $(basename "$backup")"
  fi
  cp -r "$here/themes/$v" "$target" || die "could not copy the $v theme into $themes_dir"
  # A .git directory here would make Omarchy treat the theme as a stranger's and
  # drop its Lua; copying from the repo should never bring one, but make sure.
  rm -rf "$target/.git"
  echo "installed $target"
done

if [ "$do_apply" -eq 1 ]; then
  current=$(omarchy theme current 2>/dev/null | head -1)
  case "$current" in
    iOS|ios|"iOS Light"|ios-light) ;;
    "") ;;
    *) printf '%s\n' "$current" > "$state/previous-theme"; echo "your current theme ($current) is remembered for ./uninstall.sh" ;;
  esac

  echo "applying $apply..."
  omarchy theme set "$apply" || die "omarchy theme set $apply failed"

  # The theme brings Hyprland config with it; make sure Hyprland took it.
  if have hyprctl; then
    hyprctl reload >/dev/null 2>&1
    errors=$(hyprctl configerrors 2>/dev/null | grep -v "^no errors" | head -10)
    [ -n "$errors" ] && warn "Hyprland reported config errors:"$'\n'"$errors"
    rounding=$(hyprctl getoption decoration:rounding -j 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin).get("int"))' 2>/dev/null)
    [ "$rounding" = "14" ] || warn "Hyprland's rounding is '$rounding', expected 14 — the theme's hyprland.lua may not have been loaded (see README > It looks half-applied)"
  fi
fi

echo
echo "Done. Switch variants any time:"
echo "  omarchy theme set ios          # dark"
echo "  omarchy theme set ios-light    # light"
echo "  omarchy theme bg next          # next wallpaper"
echo "Undo with ./uninstall.sh"
