-- iOS Light — window look'n'feel.
--
-- Continuous ("squircle") corners, a hairline border that lights up in iOS blue,
-- frosted glass on the shell's own surfaces, and iOS timing curves.
--
-- On speed: blur is on so the bar, menus and notifications can be glass, but
-- every window is excluded from it and `xray` makes the blur sample the
-- wallpaper instead of the windows underneath. Nothing you actually work in
-- pays for the effect — see README > Performance.

local active_border = { colors = { "rgba(007affff)", "rgba(5ac8faff)" }, angle = 45 }
local inactive_border = "rgba(c7c7cc99)"

hl.config({
  general = {
    -- iOS spacing: a little air around each card, hairline edges.
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
    -- iOS corners are continuous curves, not circular arcs. rounding_power
    -- above 2 is Hyprland's approximation of exactly that.
    rounding = 14,
    rounding_power = 3.4,

    blur = {
      enabled = true,
      size = 20,
      passes = 2,
      new_optimizations = true,
      -- Sample the wallpaper, not the windows behind: cheaper, and it keeps
      -- the glass reading as one material instead of a smear of whatever is open.
      xray = true,
      noise = 0.015,
      contrast = 1.05,
      brightness = 1.08,
      -- Glass on iOS keeps the colour of what is behind it.
      vibrancy = 0.35,
      vibrancy_darkness = 0.05,
      popups = true,
      special = false,
    },

    shadow = {
      enabled = true,
      range = 18,
      render_power = 3,
      color = "rgba(0000002e)",
      color_inactive = "rgba(00000018)",
    },
  },
})

-- Windows are not blurred: the glass is for the shell's surfaces.
o.window(".*", { no_blur = true })

-- Frost the shell's own layers (bar, menus, notifications, OSD, bar panels).
-- No ignore_alpha here: with it set, Hyprland skips the blur on these surfaces entirely
-- (measured — the wallpaper comes through the bar unblurred), and the fully transparent
-- margins around a card are not blurred anyway.
local glass = "^omarchy-(bar|menu|launcher|notifications|osd|polkit|keyboard-panel|clipboard|emojis|reminders|network-qr|image-selector)$"
hl.layer_rule({ match = { namespace = glass }, blur = true })

-- iOS motion: a soft standard curve, a gentle overshoot for things that appear,
-- and a quick exit. Durations are in tenths of a second.
hl.curve("iosStandard", { type = "bezier", points = { { 0.32, 0.72 }, { 0, 1 } } })
hl.curve("iosSpring", { type = "bezier", points = { { 0.34, 1.32 }, { 0.64, 1 } } })
hl.curve("iosExit", { type = "bezier", points = { { 0.4, 0 }, { 1, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3.2, bezier = "iosSpring" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.4, bezier = "iosSpring", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "iosExit", style = "popin 94%" })
hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "iosStandard" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.4, bezier = "iosStandard" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2, bezier = "iosStandard" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.6, bezier = "iosExit" })
hl.animation({ leaf = "layers", enabled = true, speed = 3, bezier = "iosStandard" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "iosSpring", style = "popin 95%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "iosExit", style = "fade" })
-- Workspaces slide like Home Screen pages. Set enabled = false for instant switching.
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.5, bezier = "iosStandard", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.5, bezier = "iosStandard", style = "slidevert" })
