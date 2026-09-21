# Customizing Golden Apple

Edit the installed copy in `~/.config/omarchy/themes/golden-apple/` (or the light one), then re-apply:

```bash
omarchy theme set golden-apple
```

Re-running `./install.sh` overwrites your edits (the old folder is kept as `golden-apple.bak.<timestamp>`).
To keep changes, edit the files in the repo and install from there.

## Glass

| Want | Change |
|---|---|
| More or less gold in menus / bar | `background` and `background-alpha` under `[menu]`, `[popups]`, `[bar]` in `shell.toml` |
| Stronger blur | `size` and `passes` in `hyprland.lua` `blur = {...}` (passes cost the most) |
| No blur at all | `blur = { enabled = false }` |
| More solid terminal | raise `alpha` in `foot.ini` (`0.82` dark, `0.90` light) |
| Solid terminal | `alpha=1.0` |
| Softer/harder window fade | the `opacity = "0.97 0.93"` rule (active, inactive) |

## Shape and motion

- Corner radius: `rounding` in `hyprland.lua` (14). Higher `rounding_power` looks squarer-round; `2` is a circle arc.
- Gaps: `gaps_in`, `gaps_out`.
- Instant workspace switching: set `enabled = false` on the `workspaces` animation.
- The bar's height and font size: `size-horizontal` and `[font] base-size` in `shell.toml`.

## Colours

`colors.toml` is the source of truth for the terminal, editors and apps. The bar, menus and borders have
their own values in `shell.toml` and `hyprland.lua`; change both if you change the accent. The accent
appears as `e8c77d` / `c79a3a` (dark) and `a87a1f` (light).

## Wallpapers

```bash
tools/add-wallpaper.sh ~/Pictures/photo.jpg                       # dark variant
tools/add-wallpaper.sh ~/Pictures/photo.jpg golden-apple-light    # light variant
tools/add-wallpaper.sh ~/Pictures/photo.jpg --repo                # bundle into this repo
omarchy theme bg next                                             # cycle
```

Wallpapers you add live in `~/.config/omarchy/backgrounds/<theme>/` and survive reinstalling. Regenerate
the gradients at your screen's resolution with `./install.sh --wallpapers` or
`tools/make-wallpapers.sh 3840x2160`. Photographs make the blur visible; flat gradients give it nothing to
blur.

## Making it leaner

See "Performance" in the README. The three biggest savings are disabling blur, disabling the workspace
animation, and setting terminal `alpha=1.0`.
