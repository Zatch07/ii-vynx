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
          colors.bg = "#091612"
          colors.fg = "#d7e6df"
          colors.bg_dark = "#334c44"
          colors.bg_float = "#091612"
          colors.bg_highlight = "#2b3733"
          colors.bg_popup = "#16221e"
          colors.bg_search = "#85d6bf"
          colors.bg_sidebar = "#121e1a"
          colors.bg_statusline = "#16221e"
          colors.bg_visual = "#334c44"
          colors.border = "#7c968d"
          colors.fg_dark = "#b1ccc3"
          colors.fg_float = "#d7e6df"
          colors.fg_gutter = "#334c44"
          colors.fg_sidebar = "#b1ccc3"
          colors.blue = "#b0d36d"
          colors.blue0 = "#364e00"
          colors.blue1 = "#b0d36d"
          colors.blue2 = "#b0d36d"
          colors.blue5 = "#b0d36d"
          colors.blue6 = "#b0d36d"
          colors.blue7 = "#b0d36d"
          colors.cyan = "#b7d085"
          colors.dark3 = "#334c44"
          colors.dark5 = "#334c44"
          colors.error = "#ffb4ab"
          colors.green = "#85d6bf"
          colors.green1 = "#85d6bf"
          colors.green2 = "#85d6bf"
          colors.hint = "#b7d085"
          colors.info = "#b0d36d"
          colors.magenta = "#85d6bf"
          colors.magenta2 = "#85d6bf"
          colors.orange = "#ffb4ab"
          colors.purple = "#b0d36d"
          colors.red = "#ffb4ab"
          colors.red1 = "#ffb4ab"
          colors.teal = "#b7d085"
          colors.terminal_black = "#091612"
          colors.warning = "#ffb4ab"
          colors.yellow = "#b7d085"
        end,
      }
    end,
  }
}
