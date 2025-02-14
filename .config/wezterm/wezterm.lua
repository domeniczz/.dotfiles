local wezterm = require ("wezterm")
local config = wezterm.config_builder()

config.hide_tab_bar_if_only_one_tab = true
config.switch_to_last_active_tab_when_closing_tab = true

config.window_background_opacity = 0.85
config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

config.font_size = 10.0
config.font = wezterm.font 'JetBrains Mono'

config.automatically_reload_config = true
config.adjust_window_size_when_changing_font_size = false
config.enable_scroll_bar = true
config.hide_mouse_cursor_when_typing = true
config.window_close_confirmation = 'NeverPrompt'

config.colors = {
  foreground = '#fcfcfc',
  background = '#020202',
  ansi = {
    '#232627',
    '#ed1515',
    '#11d116',
    '#f67400',
    '#1d99f3',
    '#9b59b6',
    '#1abc9c',
    '#fcfcfc',
  },
  brights = {
    '#7f8c8d',
    '#c0392b',
    '#1cdc9a',
    '#fdbc4b',
    '#3daee9',
    '#8e44ad',
    '#16a085',
    '#ffffff',
  },
}

return config
