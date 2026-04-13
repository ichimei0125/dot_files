local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_prog = { 'pwsh.exe' }
config.default_cwd = wezterm.home_dir

config.initial_cols = 100
config.initial_rows = 25

-- Optional: Aesthetics
-- config.color_scheme = 'AdventureTime' -- Browse 700+ schemes at https://wezfurlong.org
-- config.font = wezterm.font 'Fira Code' -- Ensure the font is installed on your system
-- config.font_size = 11.0

return config
