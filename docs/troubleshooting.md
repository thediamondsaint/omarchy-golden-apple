# Troubleshooting

Check what is applied: `omarchy theme current` (should say **Golden Apple**), `hyprctl configerrors`
(should say no errors), `hyprctl getoption decoration:rounding` (should be 14).

| Symptom | Cause and fix |
|---|---|
| Colours changed but corners are square and nothing is frosted | The theme was installed as a git clone (`omarchy theme install <url>`) and Omarchy dropped the Lua and `foot.ini`. Run `./install.sh` from this repo. |
| `omarchy theme set Golden Apple` fails | Use the folder name: `omarchy theme set golden-apple`. |
| Some bar icons black, some cream | The bar is in "transparent" mode. `omarchy bar transparent false` (the installer does this). |
| Windows are translucent but what shows through is sharp | Hyprland keeps window rules registered by a previously applied theme across `hyprctl reload`. Log out and back in once. Bar and menus blur immediately either way. |
| An app is fully opaque | Only apps that draw transparent backgrounds can be glass. foot does via `alpha`; most Electron/GTK apps cannot. |
| Blur is invisible | A flat wallpaper has nothing to blur; use a photograph such as the lion. |
| Terminal is not transparent | Terminals other than foot are not covered. In foot, `alpha` must be inside `[colors-dark]` in `foot.ini`. |
| Wallpaper did not change | `omarchy theme bg set <full path>`; list what the theme has with `ls ~/.local/state/omarchy/current/theme/backgrounds/`. |
| Slow or stuttering | Set `blur = { enabled = false }` and/or disable the workspace animation (README > Performance). |

## Starting over

```bash
./uninstall.sh            # switches back to your previous theme and removes both variants
./install.sh              # a clean install
```

`./uninstall.sh --keep` switches away but leaves the theme files in place.

## Reporting a bug

Open an issue with the output of `omarchy version`, `hyprctl version | head -1`, `hyprctl configerrors`
and a description or screenshot of what looks wrong.
