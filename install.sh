#!/usr/bin/env bash
# Install the Golden Apple theme for Omarchy.
#
#   ./install.sh              install both variants and switch to Golden Apple (dark)
#   ./install.sh --light      ... and switch to Golden Apple Light instead
#   ./install.sh --no-apply   install them but keep your current theme
#   ./install.sh --wallpapers regenerate the wallpapers at this display's resolution first
#   ./install.sh --check      say what would happen, change nothing
#
# The theme is COPIED into ~/.config/omarchy/themes/. That is deliberate:
# `omarchy theme install <git-url>` clones instead, and Omarchy refuses to load
# Lua from a cloned theme — which is exactly where the window shape, the glass
# and the animations live. A copied theme is yours, so all of it applies.
#
# The dark theme's files sit at the root of this repo (that is what makes
# `omarchy theme install` give at least the colours), and the light one lives in
# themes/golden-apple-light.
set -uo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
themes_dir="$HOME/.config/omarchy/themes"
state="$HOME/.local/state/omarchy-golden-apple"
variants=(golden-apple golden-apple-light)
apply=golden-apple
do_apply=1
check=0
regen=0

for arg in "$@"; do
  case "$arg" in
    --light) apply=golden-apple-light ;;
    --dark) apply=golden-apple ;;
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

# Where each variant's files are in this repo: the dark one at the root, the light one below.
source_of() { case "$1" in golden-apple) echo "$here" ;; *) echo "$here/themes/$1" ;; esac; }
# The files a theme is made of — the rest of the repo (README, install.sh, tools) stays out.
theme_files=(colors.toml hyprland.lua shell.toml foot.ini icons.theme preview.png backgrounds)

# A theme folder that is this repo cloned in by `omarchy theme install`: it has no
# colors.toml of its own at that point, so Omarchy cannot theme anything from it.
is_clone_of_this_repo() { [ -d "$1/.git" ] && [ -f "$1/install.sh" ] && [ -d "$1/themes" ]; }

have omarchy || die "omarchy is not on PATH — this is a theme for Omarchy (https://omarchy.org)"
version=$(omarchy version 2>/dev/null | head -1)
case "$version" in
  3.*|2.*|1.*) die "this theme is for Omarchy 4: it styles the Quickshell bar and uses Lua Hyprland config. This machine runs Omarchy $version." ;;
esac
[ -d "$HOME/.config/omarchy" ] || die "no ~/.config/omarchy here; is this an Omarchy install?"

echo "Omarchy $version"
if [ "$check" -eq 1 ]; then
  for v in "${variants[@]}"; do
    if is_clone_of_this_repo "$themes_dir/$v"; then
      echo "  would replace $themes_dir/$v, which is this repo cloned in by \`omarchy theme install\`"
    elif [ -d "$themes_dir/$v" ]; then
      echo "  would replace $themes_dir/$v (a backup copy is kept)"
    else
      echo "  would install $themes_dir/$v"
    fi
    printf '    from %s: %s\n' "$(source_of "$v")" "${theme_files[*]}"
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
  if is_clone_of_this_repo "$target"; then
    rm -rf "$target"
    echo "replaced the git-cloned copy at $target (a cloned theme cannot carry the Lua)"
  elif [ -e "$target" ]; then
    backup="$target.bak.$(date +%s)"
    mv "$target" "$backup" || die "could not move $target aside"
    echo "kept your existing $v theme as $(basename "$backup")"
  fi
  mkdir -p "$target"
  src=$(source_of "$v")
  for f in "${theme_files[@]}"; do
    [ -e "$src/$f" ] || continue
    cp -r "$src/$f" "$target/" || die "could not copy $f into $target"
  done
  [ -f "$target/colors.toml" ] || die "no colors.toml for $v in $src"
  # A .git directory here would make Omarchy treat the theme as a stranger's and
  # drop its Lua; copying file by file should never bring one, but make sure.
  rm -rf "$target/.git"
  echo "installed $target"
done

if [ "$do_apply" -eq 1 ]; then
  # `omarchy theme current` title-cases the folder name, so this theme reports as "Golden Apple".
  # Remember anything else as what to go back to — and never remember this theme as its own predecessor.
  current=$(omarchy theme current 2>/dev/null | head -1)
  case "${current,,}" in
    golden-apple|"golden apple"|"golden apple light"|golden-apple-light|"") ;;
    *) printf '%s\n' "$current" > "$state/previous-theme"; echo "your current theme ($current) is remembered for ./uninstall.sh" ;;
  esac

  echo "applying $apply..."
  omarchy theme set "$apply" || die "omarchy theme set $apply failed"

  # A "transparent" bar has no surface of its own and picks black or cream text from the
  # wallpaper under it, which is how you get half the icons black and half cream. The
  # theme's bar is a tinted glass surface with fixed theme text, so turn that mode off
  # (remembered, so ./uninstall.sh can put it back).
  if have jq && [ "$(jq -r '.bar.transparent // false' "$HOME/.config/omarchy/shell.json" 2>/dev/null)" = "true" ]; then
    if omarchy bar transparent false >/dev/null 2>&1; then
      : > "$state/bar-was-transparent"
      echo "turned off the bar's 'transparent' mode so its icons follow the theme (./uninstall.sh restores it)"
    fi
  fi

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
echo "  omarchy theme set golden-apple         # dark"
echo "  omarchy theme set golden-apple-light   # light"
echo "  omarchy theme bg next                  # next wallpaper"
echo "Undo with ./uninstall.sh"
