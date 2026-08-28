-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

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

-- Gruvbox in both flavours. The tab bar is hand-painted (see format-tab-title
-- below), so its colours have to be carried alongside the scheme name rather
-- than coming from the scheme itself.
local themes = {
  dark = {
    scheme = 'Gruvbox dark, medium (base16)',
    bg = '#282828',
    fg = '#ebdbb2',
    active_bg = '#d65d0e',
    active_fg = '#282828',
    inactive_bg = '#3c3836',
    inactive_fg = '#a89984',
    hover_bg = '#504945',
    hover_fg = '#ebdbb2',
  },
  light = {
    scheme = 'Gruvbox light, medium (base16)',
    bg = '#fbf1c7',
    fg = '#3c3836',
    active_bg = '#d65d0e',
    active_fg = '#fbf1c7',
    inactive_bg = '#ebdbb2',
    inactive_fg = '#7c6f64',
    hover_bg = '#d5c4a1',
    hover_fg = '#3c3836',
  },
}

local function tab_bar_colors(theme)
  return {
    tab_bar = {
      background = theme.bg,
      new_tab = { bg_color = theme.bg, fg_color = theme.fg },
      new_tab_hover = { bg_color = theme.hover_bg, fg_color = theme.hover_fg },
    },
  }
end

-- The scheme name is the single source of truth for which theme is live, so the
-- tab-bar painter can recover it from whatever config it is handed.
local function theme_of(scheme)
  return scheme == themes.light.scheme and themes.light or themes.dark
end

config.color_scheme = themes.dark.scheme
config.colors = tab_bar_colors(themes.dark)

-- WezTerm has no built-in scheme switch; per-window config overrides are the
-- supported way to flip one at runtime. F12 because nothing downstream claims
-- it -- zsh, tmux and nvim all leave it alone.
wezterm.on('toggle-theme', function(window, _pane)
  local overrides = window:get_config_overrides() or {}
  local current = overrides.color_scheme or config.color_scheme
  local next_theme = current == themes.light.scheme and themes.dark or themes.light
  overrides.color_scheme = next_theme.scheme
  overrides.colors = tab_bar_colors(next_theme)
  window:set_config_overrides(overrides)
end)

config.enable_tab_bar = true
-- One tab needs no tab bar; it is just another line of chrome to ignore.
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 8
config.adjust_window_size_when_changing_font_size = false
config.window_decorations = "RESIZE"
config.exit_behavior = 'Close'

-- Leader key (CTRL+Q, avoids conflict with nvim/tmux default CTRL+B)
config.leader = { key = 'q', mods = 'CTRL', timeout_milliseconds = 1000 }

-- smart_ssh: pick an SSH host from ~/.ssh/config for a new tab or split.
local smart_ssh = wezterm.plugin.require('https://github.com/DavidRR-F/smart_ssh.wezterm')

-- ALT+<n> jumps straight to tab n, matching the numbers the tab bar now shows.
-- CTRL+SHIFT+<n> does this by default, but is a three-key stretch. Nothing else claims
-- bare ALT+<digit>: tmux's M-1..M-5 layout keys sit behind the C-a prefix, nvim maps
-- none, and GNOME uses SUPER+<n> for the dock. The one casualty is zsh's digit-argument
-- (ESC-<n> numeric prefix), which WezTerm now swallows before the shell sees it.
config.keys = {
  { key = 'F12', mods = 'NONE', action = wezterm.action.EmitEvent 'toggle-theme' },
  { key = 's', mods = 'LEADER|SHIFT', action = smart_ssh.tab() },    -- ssh in new tab
  { key = '5', mods = 'LEADER',       action = smart_ssh.hsplit() }, -- ssh in horizontal split
  { key = "'", mods = 'LEADER',       action = smart_ssh.vsplit() }, -- ssh in vertical split
  -- Quick note (floating, centered) via ~/.config/wezterm/open-note.sh
  { key = 'n', mods = 'LEADER', action = wezterm.action_callback(function(_, _)
    local timestamp = os.date('%Y-%m-%d_%H%M%S')
    local note = '/tmp/note_' .. timestamp .. '.md'
    local f = io.open(note, 'w')
    if f then
      f:write('# Note — ' .. os.date('%Y-%m-%d %H:%M') .. '\n\n')
      f:close()
    end
    local home = os.getenv('HOME')
    os.execute(string.format('%s/.config/wezterm/open-note.sh "%s" &', home, note))
  end) },
}
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'ALT',
    action = wezterm.action.ActivateTab(i - 1),
  })
end
smart_ssh.apply_to_config(config)

-- Tabs show their number only. The title was three bars' worth of noise stacked with
-- tmux's status line and airline; the index is the part actually used to switch tabs.
-- Flat blocks butted straight against each other, i3-style -- no powerline divider,
-- so no glyph whose slant has to line up with the next tab's colour.
wezterm.on('format-tab-title', function(tab, _tabs, _panes, conf, hover, _max_width)
  local theme = theme_of(conf.color_scheme)
  local is_active = tab.is_active
  local tab_bg = is_active and theme.active_bg or (hover and theme.hover_bg or theme.inactive_bg)
  local tab_fg = is_active and theme.active_fg or (hover and theme.hover_fg or theme.inactive_fg)

  return {
    { Background = { Color = tab_bg } },
    { Foreground = { Color = tab_fg } },
    { Text = '  ' .. tostring(tab.tab_index + 1) .. '  ' },
  }
end)

-- Finally, return the configuration to wezterm:
return config
