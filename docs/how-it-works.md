# How Golden Apple works

Omarchy 4 themes are a folder in `~/.config/omarchy/themes/<name>/`. Golden Apple uses every layer
Omarchy offers, and each one is a different file.

| File | Read by | What it does |
|---|---|---|
| `colors.toml` | Omarchy's templates | The palette. Omarchy renders terminal, editor, browser and GTK colours from it. |
| `shell.toml` | The Omarchy shell (Quickshell) | Surfaces of the bar, menus, launcher, popups and notifications: tint, alpha, border, selection. |
| `hyprland.lua` | Hyprland | Corner rounding, borders, shadow, blur, layer rules, animation curves. |
| `foot.ini` | The foot terminal | Terminal colours **and** the `alpha` that makes it transparent. |
| `icons.theme` | Omarchy | Icon theme name. |
| `backgrounds/` | `omarchy theme bg` | The wallpapers in the rotation. |
| `preview.png` | The theme picker | Thumbnail. |

## Where the glass comes from

Glass is three separate mechanisms, because no single switch makes everything translucent:

1. **Shell surfaces** (bar, menus, notifications, OSD): `shell.toml` gives each a translucent tinted
   colour, and `hyprland.lua` adds a layer rule that blurs the layers named `omarchy-*`.
2. **The terminal**: foot draws its own background transparent through `alpha` in `foot.ini`. The text stays
   opaque, and it costs nothing because there is no compositor effect involved.
3. **Other windows**: a gentle Hyprland opacity rule (`0.97 0.93`). Apps that cannot draw a transparent
   background (most Electron and GTK apps) are only lightly faded.

Blur runs with `xray = true`, meaning it samples the wallpaper instead of every window underneath. That is
what keeps the cost flat as you open more windows.

## The gold

- Accent `#e8c77d` (champagne) with `#c79a3a` for the border gradient's far end.
- Surfaces use `#1c1710`, a black with gold in it, at 62 % alpha. The tint is in the surface colour, not
  the blur, so it stays consistent over any wallpaper.
- The selected menu row is a solid gold pill with dark text.
- The ANSI palette is warm so terminals do not look cold beside the accent; blue is a dusty slate.
- Light variant: the same structure on `#faf6ec` paper with a deeper gold (`#a87a1f`) so text keeps contrast.

## Bar icons follow the theme

Omarchy's bar has a `transparent` mode in which it samples the wallpaper under the bar and chooses black or
cream text for whichever contrasts better. Widgets that read the bar's foreground follow that choice; others
use the theme text, which is why a transparent bar can show a mix. Golden Apple's bar is a tinted glass
surface with fixed theme text instead, so `install.sh` turns transparent mode off
(`omarchy bar transparent false`) and `uninstall.sh` restores it.

## Why an installer instead of `omarchy theme install <url>`

Omarchy deliberately drops Lua files and terminal configs from themes installed by URL, since they can run
code. The corners, blur, motion and terminal transparency are exactly those files, so `install.sh` copies
them into place. Installing by URL still works and gives the palette, wallpapers and shell surfaces; the
dark variant's files live at the repo root for that reason.

## Repo layout

```
colors.toml hyprland.lua shell.toml foot.ini icons.theme   dark variant (repo root)
backgrounds/                                               dark wallpapers (lion + 4 gradients)
themes/golden-apple-light/                                 the light variant, same files
tools/make-wallpapers.sh                                   regenerate the gradients (ImageMagick)
tools/add-wallpaper.sh                                     add your own image
install.sh / uninstall.sh                                  copy in / switch back and remove
docs/                                                      screenshots and these pages
```
