-- Golden Apple Light — window look'n'feel.
--
-- Everything is glass: windows are translucent and blurred, and so are the bar,
-- the menus, the notifications and the bar's own panels. Corners are continuous
-- (the squircle iOS draws), borders are a hairline of light gold, and motion
-- follows Apple's curves.
--
-- On speed: the blur runs with `xray` on, so it samples the wallpaper rather than
-- the stack of windows underneath. That keeps one consistent material instead of a
-- smear of whatever is open, and it costs the same whether one window is open or
-- twenty. Two passes is the whole budget — README > Performance has the two lines
-- that turn the glass off if you want it flat.

local active_border = { colors = { "rgba(c79a3aff)", "rgba(a87a1fff)" }, angle = 45 }
local inactive_border = "rgba(c9b58c99)"

hl.config({
  general = {
    border_size = 1,
    gaps_in = 6,
    gaps_out = 12,

    col = {
      active_border = active_border,
      inactive_border = inactive_border,
    },
  },

  group = {
    col = {
      border_active = active_border,
      border_inactive = inactive_border,
    },
  },

  decoration = {
    -- Continuous corners, not circular arcs: rounding_power above 2 is Hyprland's
    -- approximation of the squircle.
    rounding = 14,
    rounding_power = 3.4,

    blur = {
      enabled = true,
      size = 20,
      passes = 2,
      new_optimizations = true,
      xray = true,
      noise = 0.015,
      contrast = 1.05,
      brightness = 1.08,
      -- Glass keeps the colour of whatever is behind it; the surfaces do the gold tinting.
      vibrancy = 0.35,
      vibrancy_darkness = 0.05,
      popups = true,
      special = true,
    },

    shadow = {
      enabled = true,
      range = 18,
      render_power = 3,
      color = "rgba(3a2c1029)",
      color_inactive = "rgba(3a2c1016)",
    },
  },
})

-- Windows get a light haze. The real terminal glass comes from foot.ini's `alpha`,
-- which makes the background transparent while leaving text opaque; this rule only
-- adds a little air for everything else. Omarchy tags windows `default-opacity` and
-- gives them 0.985/0.96, and this file loads after that, so these values win. Apps
-- that opt out of the tag (video, image viewers) stay opaque, which is what you want.
o.window({ tag = "default-opacity" }, { opacity = "0.97 0.94" })

-- Frost the shell's own layers (bar, menus, notifications, OSD, bar panels).
-- No ignore_alpha here: with it set, Hyprland skips the blur on these surfaces entirely
-- (measured — the wallpaper comes through the bar unblurred), and the fully transparent
-- margins around a card are not blurred anyway.
local glass = "^omarchy-(bar|menu|launcher|notifications|osd|polkit|keyboard-panel|clipboard|emojis|reminders|network-qr|image-selector)$"
hl.layer_rule({ match = { namespace = glass }, blur = true })

-- Motion: a soft standard curve, a gentle overshoot for things that appear, and a
-- quick exit. Durations are in tenths of a second.
hl.curve("goldStandard", { type = "bezier", points = { { 0.32, 0.72 }, { 0, 1 } } })
hl.curve("goldSpring", { type = "bezier", points = { { 0.34, 1.32 }, { 0.64, 1 } } })
hl.curve("goldExit", { type = "bezier", points = { { 0.4, 0 }, { 1, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3.2, bezier = "goldSpring" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.4, bezier = "goldSpring", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "goldExit", style = "popin 94%" })
hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "goldStandard" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.4, bezier = "goldStandard" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2, bezier = "goldStandard" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.6, bezier = "goldExit" })
hl.animation({ leaf = "layers", enabled = true, speed = 3, bezier = "goldStandard" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "goldSpring", style = "popin 95%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "goldExit", style = "fade" })
-- Workspaces slide like Home Screen pages. Set enabled = false for instant switching.
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.5, bezier = "goldStandard", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.5, bezier = "goldStandard", style = "slidevert" })
