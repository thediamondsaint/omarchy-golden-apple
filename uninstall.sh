#!/usr/bin/env bash
# Remove the Golden Apple theme and put your previous theme back.
#
#   ./uninstall.sh              switch away, then delete both Golden Apple themes
#   ./uninstall.sh --keep       switch away but leave the theme files installed
set -uo pipefail

themes_dir="$HOME/.config/omarchy/themes"
state="$HOME/.local/state/omarchy-golden-apple"
keep=0
for arg in "$@"; do
  case "$arg" in
    --keep) keep=1 ;;
    -h|--help) sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

command -v omarchy >/dev/null 2>&1 || { echo "needs omarchy on PATH" >&2; exit 1; }

current=$(omarchy theme current 2>/dev/null | head -1)
case "${current,,}" in
  "golden apple"|golden-apple|"golden apple light"|golden-apple-light)
    previous=""
    [ -f "$state/previous-theme" ] && previous=$(head -1 "$state/previous-theme")
    # A previous install may have recorded this theme as its own predecessor; ignore that.
    case "${previous,,}" in "golden apple"|golden-apple|"golden apple light"|golden-apple-light) previous="" ;; esac
    if [ -z "$previous" ]; then
      # Nothing remembered (installed by hand, say): fall back to a stock theme.
      previous="Tokyo Night"
      echo "no remembered theme, falling back to $previous"
    fi
    echo "switching back to $previous..."
    omarchy theme set "$previous" >/dev/null 2>&1 || {
      echo "could not switch to '$previous'; pick one yourself: omarchy theme list" >&2
    }
    ;;
  *) echo "the Golden Apple theme is not the current one ($current), leaving the theme as it is" ;;
esac

if [ "$keep" -eq 0 ]; then
  for v in golden-apple golden-apple-light; do
    if [ -d "$themes_dir/$v" ]; then
      rm -rf "$themes_dir/$v" && echo "removed $themes_dir/$v"
    fi
  done
  rm -f "$state/previous-theme"
  shopt -s nullglob
  saved=("$themes_dir"/golden-apple.bak.* "$themes_dir"/golden-apple-light.bak.*)
  shopt -u nullglob
  if [ "${#saved[@]}" -gt 0 ]; then
    echo
    echo "these are copies of themes that were at those names before the install:"
    printf '  %s\n' "${saved[@]}"
    echo "rename one back if you want it: mv <dir> $themes_dir/golden-apple"
  fi
fi

echo "done"
