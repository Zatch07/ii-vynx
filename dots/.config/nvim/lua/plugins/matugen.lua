return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = function()
      return {
        transparent = true, -- Matches Neovim background to Kitty background
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
        on_colors = function(colors)
          -- Inject Matugen Material You Colors Dynamically
          colors.bg = "#1a1111"
          colors.fg = "#f1dedd"
          colors.bg_dark = "#534342"
          colors.bg_float = "#1a1111"
          colors.bg_highlight = "#3d3231"
          colors.bg_popup = "#271d1d"
          colors.bg_search = "#e2c28c"
          colors.bg_sidebar = "#231919"
          colors.bg_statusline = "#271d1d"
          colors.bg_visual = "#534342"
          colors.border = "#a08c8b"
          colors.fg_dark = "#d8c1c0"
          colors.fg_float = "#f1dedd"
          colors.fg_gutter = "#534342"
          colors.fg_sidebar = "#d8c1c0"
          colors.blue = "#ffb3af"
          colors.blue0 = "#733331"
          colors.blue1 = "#ffb3af"
          colors.blue2 = "#ffb3af"
          colors.blue5 = "#ffb3af"
          colors.blue6 = "#ffb3af"
          colors.blue7 = "#ffb3af"
          colors.cyan = "#e7bdba"
          colors.dark3 = "#534342"
          colors.dark5 = "#534342"
          colors.error = "#ffb4ab"
          colors.green = "#e2c28c"
          colors.green1 = "#e2c28c"
          colors.green2 = "#e2c28c"
          colors.hint = "#e7bdba"
          colors.info = "#ffb3af"
          colors.magenta = "#e2c28c"
          colors.magenta2 = "#e2c28c"
          colors.orange = "#ffb4ab"
          colors.purple = "#ffb3af"
          colors.red = "#ffb4ab"
          colors.red1 = "#ffb4ab"
          colors.teal = "#e7bdba"
          colors.terminal_black = "#1a1111"
          colors.warning = "#ffb4ab"
          colors.yellow = "#e7bdba"
        end,
      }
    end,
  }
}
