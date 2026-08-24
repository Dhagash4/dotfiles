-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
-- config.initial_cols = 640
-- config.initial_rows = 480

-- or, changing the font size and color scheme.
-- Prefer the patched SFMono (installed by ~/.config/fonts/install_fonts.sh); the
-- fallbacks keep glyphs rendering on a machine where it is missing instead of
-- leaving the terminal on whatever WezTerm picks by itself.
config.font = wezterm.font_with_fallback {
  'SFMono Nerd Font',
  'Symbols Nerd Font Mono',
  'DejaVu Sans Mono',
  'monospace',
}
config.font_size = 16
-- Don't pop up a warning window when a glyph is missing from the font stack.
config.warn_about_missing_glyphs = false
config.color_scheme = 'Gruvbox dark, medium (base16)'

config.enable_tab_bar = true
-- One tab needs no tab bar; it is just another line of chrome to ignore.
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 8
config.adjust_window_size_when_changing_font_size = false
config.window_decorations = "RESIZE"
config.exit_behavior = 'Close'

-- ALT+<n> jumps straight to tab n, matching the numbers the tab bar now shows.
-- CTRL+SHIFT+<n> does this by default, but is a three-key stretch. Nothing else claims
-- bare ALT+<digit>: tmux's M-1..M-5 layout keys sit behind the C-a prefix, nvim maps
-- none, and GNOME uses SUPER+<n> for the dock. The one casualty is zsh's digit-argument
-- (ESC-<n> numeric prefix), which WezTerm now swallows before the shell sees it.
config.keys = {}
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'ALT',
    action = wezterm.action.ActivateTab(i - 1),
  })
end

-- Gruvbox colors for the tab bar
local bg = '#282828'
local fg = '#ebdbb2'
local active_bg = '#d65d0e'
local active_fg = '#282828'
local inactive_bg = '#3c3836'
local inactive_fg = '#a89984'
local hover_bg = '#504945'
local hover_fg = '#ebdbb2'

config.colors = {
  tab_bar = {
    background = bg,
    new_tab = { bg_color = bg, fg_color = fg },
    new_tab_hover = { bg_color = hover_bg, fg_color = hover_fg },
  },
}

-- Tabs show their number only. The title was three bars' worth of noise stacked with
-- tmux's status line and airline; the index is the part actually used to switch tabs.
-- Flat blocks butted straight against each other, i3-style -- no powerline divider,
-- so no glyph whose slant has to line up with the next tab's colour.
wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, hover, _max_width)
  local is_active = tab.is_active
  local tab_bg = is_active and active_bg or (hover and hover_bg or inactive_bg)
  local tab_fg = is_active and active_fg or (hover and hover_fg or inactive_fg)

  return {
    { Background = { Color = tab_bg } },
    { Foreground = { Color = tab_fg } },
    { Text = '  ' .. tostring(tab.tab_index + 1) .. '  ' },
  }
end)

-- Finally, return the configuration to wezterm:
return config
