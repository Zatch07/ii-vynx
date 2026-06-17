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
          colors.bg = "#091518"
          colors.fg = "#d8e5e9"
          colors.bg_dark = "#334a50"
          colors.bg_float = "#091518"
          colors.bg_highlight = "#2b373a"
          colors.bg_popup = "#162124"
          colors.bg_search = "#84d2e5"
          colors.bg_sidebar = "#121d20"
          colors.bg_statusline = "#162124"
          colors.bg_visual = "#334a50"
          colors.border = "#7d959b"
          colors.fg_dark = "#b2cbd2"
          colors.fg_float = "#d8e5e9"
          colors.fg_gutter = "#334a50"
          colors.fg_sidebar = "#b2cbd2"
          colors.blue = "#6edbaa"
          colors.blue0 = "#005237"
          colors.blue1 = "#6edbaa"
          colors.blue2 = "#6edbaa"
          colors.blue5 = "#6edbaa"
          colors.blue6 = "#6edbaa"
          colors.blue7 = "#6edbaa"
          colors.cyan = "#8ed5b1"
          colors.dark3 = "#334a50"
          colors.dark5 = "#334a50"
          colors.error = "#ffb4ab"
          colors.green = "#84d2e5"
          colors.green1 = "#84d2e5"
          colors.green2 = "#84d2e5"
          colors.hint = "#8ed5b1"
          colors.info = "#6edbaa"
          colors.magenta = "#84d2e5"
          colors.magenta2 = "#84d2e5"
          colors.orange = "#ffb4ab"
          colors.purple = "#6edbaa"
          colors.red = "#ffb4ab"
          colors.red1 = "#ffb4ab"
          colors.teal = "#8ed5b1"
          colors.terminal_black = "#091518"
          colors.warning = "#ffb4ab"
          colors.yellow = "#8ed5b1"
        end,
      }
    end,
  }
}
