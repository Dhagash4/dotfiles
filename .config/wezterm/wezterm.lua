-- Pull in the wezterm API
local wezterm = require 'wezterm'
local action = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Plugins
local smart_ssh = wezterm.plugin.require("https://github.com/DavidRR-F/smart_ssh.wezterm")
config.keys = {
  { key = "s", mods = "LEADER|SHIFT", action = smart_ssh.tab() },      -- new tab
  { key = "5", mods = "LEADER",       action = smart_ssh.hsplit() },   -- horizontal split
  { key = "'", mods = "LEADER",       action = smart_ssh.vsplit() },   -- vertical split
  -- { key = "|", mods = "LEADER|SHIFT", action = action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  -- { key = "-", mods = "LEADER",       action = action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = "n", mods = "LEADER",       action = wezterm.action_callback(function(_, _)
    local timestamp = os.date('%Y-%m-%d_%H%M%S')
    local note = '/tmp/note_' .. timestamp .. '.md'
    local f = io.open(note, 'w')
    if f then
      f:write('# Note — ' .. os.date('%Y-%m-%d %H:%M') .. '\n\n')
      f:close()
    end

    local home = os.getenv('HOME')
    os.execute(string.format('%s/.config/wezterm/open-note.sh "%s" &', home, note))
  end) },  -- quick note (floating, centered)
}
smart_ssh.apply_to_config(config)


-- Minimal numbered tab bar at the top (no powerline — avoids clashing with
-- nvim/tmux statuslines). Tabs show just their index: 1, 2, 3 ...
wezterm.on('format-tab-title', function(tab)
  local i = tab.tab_index + 1
  if tab.is_active then
    return {
      { Background = { Color = '#fabd2f' } },
      { Foreground = { Color = '#282828' } },
      { Text = ' ' .. i .. ' ' },
    }
  end
  return {
    { Foreground = { Color = '#a89984' } },
    { Text = ' ' .. i .. ' ' },
  }
end)

-- Keep the left/right status empty (no NORMAL/cpu/time/battery powerline).
wezterm.on('update-status', function(window, _)
  window:set_left_status('')
  window:set_right_status('')
end)

-- Leader key (CTRL+A, avoids conflict with nvim/tmux default CTRL+B)
config.leader = { key = 'q', mods = 'CTRL', timeout_milliseconds = 1000 }

-- Font and appearance
config.font = wezterm.font('SFMono Nerd Font')
config.font_size = 16
config.color_scheme = 'Gruvbox dark, medium (base16)'

config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 8
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.colors = {
  tab_bar = {
    background = '#282828',
    new_tab = { bg_color = '#282828', fg_color = '#a89984' },
  },
}
config.adjust_window_size_when_changing_font_size = false
config.window_decorations = "RESIZE"
config.exit_behavior = 'Close'

-- Finally, return the configuration to wezterm:
return config
