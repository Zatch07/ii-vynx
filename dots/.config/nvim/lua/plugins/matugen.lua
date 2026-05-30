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
          colors.bg = "#131313"
          colors.fg = "#e2e2e2"
          colors.bg_dark = "#474747"
          colors.bg_float = "#131313"
          colors.bg_highlight = "#353535"
          colors.bg_popup = "#1f1f1f"
          colors.bg_search = "#e2e2e2"
          colors.bg_sidebar = "#1b1b1b"
          colors.bg_statusline = "#1f1f1f"
          colors.bg_visual = "#474747"
          colors.border = "#919191"
          colors.fg_dark = "#c6c6c6"
          colors.fg_float = "#e2e2e2"
          colors.fg_gutter = "#474747"
          colors.fg_sidebar = "#c6c6c6"
          colors.blue = "#ffffff"
          colors.blue0 = "#d4d4d4"
          colors.blue1 = "#ffffff"
          colors.blue2 = "#ffffff"
          colors.blue5 = "#ffffff"
          colors.blue6 = "#ffffff"
          colors.blue7 = "#ffffff"
          colors.cyan = "#c6c6c6"
          colors.dark3 = "#474747"
          colors.dark5 = "#474747"
          colors.error = "#ffb4ab"
          colors.green = "#e2e2e2"
          colors.green1 = "#e2e2e2"
          colors.green2 = "#e2e2e2"
          colors.hint = "#c6c6c6"
          colors.info = "#ffffff"
          colors.magenta = "#e2e2e2"
          colors.magenta2 = "#e2e2e2"
          colors.orange = "#ffb4ab"
          colors.purple = "#ffffff"
          colors.red = "#ffb4ab"
          colors.red1 = "#ffb4ab"
          colors.teal = "#c6c6c6"
          colors.terminal_black = "#131313"
          colors.warning = "#ffb4ab"
          colors.yellow = "#c6c6c6"
        end,
      }
    end,
  }
}
