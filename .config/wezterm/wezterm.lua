-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
-- config.initial_cols = 640
-- config.initial_rows = 480

-- or, changing the font size and color scheme.
config.font = wezterm.font('SFMono Nerd Font')
config.font_size = 16
config.color_scheme = 'Gruvbox dark, medium (base16)'

config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32
config.adjust_window_size_when_changing_font_size = false
config.window_decorations = "RESIZE"
config.exit_behavior = 'Close'

-- Gruvbox colors for powerline tab bar
local bg = '#282828'
local fg = '#ebdbb2'
local active_bg = '#d65d0e'
local active_fg = '#282828'
local inactive_bg = '#3c3836'
local inactive_fg = '#a89984'
local hover_bg = '#504945'
local hover_fg = '#ebdbb2'

local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

config.colors = {
  tab_bar = {
    background = bg,
    new_tab = { bg_color = bg, fg_color = fg },
    new_tab_hover = { bg_color = hover_bg, fg_color = hover_fg },
  },
}

wezterm.on('format-tab-title', function(tab, tabs, panes, _config, hover, max_width)
  local title = tab.active_pane.title
  if #title > max_width - 4 then
    title = wezterm.truncate_right(title, max_width - 4) .. '…'
  end

  local is_active = tab.is_active
  local tab_bg = is_active and active_bg or (hover and hover_bg or inactive_bg)
  local tab_fg = is_active and active_fg or (hover and hover_fg or inactive_fg)

  -- Determine background to the right of this tab
  local next_tab = tabs[tab.tab_index + 2]
  local right_bg = bg
  if next_tab then
    local next_active = next_tab.is_active
    right_bg = next_active and active_bg or inactive_bg
  end

  return {
    { Background = { Color = tab_bg } },
    { Foreground = { Color = tab_fg } },
    { Text = ' ' .. title .. ' ' },
    { Background = { Color = right_bg } },
    { Foreground = { Color = tab_bg } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

-- Finally, return the configuration to wezterm:
return config
