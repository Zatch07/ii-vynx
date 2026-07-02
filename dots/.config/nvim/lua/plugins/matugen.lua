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
          colors.bg = "#121318"
          colors.fg = "#e3e1e9"
          colors.bg_dark = "#45464f"
          colors.bg_float = "#121318"
          colors.bg_highlight = "#34343a"
          colors.bg_popup = "#1f1f25"
          colors.bg_search = "#e4bad9"
          colors.bg_sidebar = "#1b1b21"
          colors.bg_statusline = "#1f1f25"
          colors.bg_visual = "#45464f"
          colors.border = "#90909a"
          colors.fg_dark = "#c6c5d0"
          colors.fg_float = "#e3e1e9"
          colors.fg_gutter = "#45464f"
          colors.fg_sidebar = "#c6c5d0"
          colors.blue = "#b8c4ff"
          colors.blue0 = "#374379"
          colors.blue1 = "#b8c4ff"
          colors.blue2 = "#b8c4ff"
          colors.blue5 = "#b8c4ff"
          colors.blue6 = "#b8c4ff"
          colors.blue7 = "#b8c4ff"
          colors.cyan = "#c2c5dd"
          colors.dark3 = "#45464f"
          colors.dark5 = "#45464f"
          colors.error = "#ffb4ab"
          colors.green = "#e4bad9"
          colors.green1 = "#e4bad9"
          colors.green2 = "#e4bad9"
          colors.hint = "#c2c5dd"
          colors.info = "#b8c4ff"
          colors.magenta = "#e4bad9"
          colors.magenta2 = "#e4bad9"
          colors.orange = "#ffb4ab"
          colors.purple = "#b8c4ff"
          colors.red = "#ffb4ab"
          colors.red1 = "#ffb4ab"
          colors.teal = "#c2c5dd"
          colors.terminal_black = "#121318"
          colors.warning = "#ffb4ab"
          colors.yellow = "#c2c5dd"
        end,
      }
    end,
  }
}
