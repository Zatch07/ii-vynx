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
          colors.bg = "#121314"
          colors.fg = "#e3e2e2"
          colors.bg_dark = "#464747"
          colors.bg_float = "#121314"
          colors.bg_highlight = "#343535"
          colors.bg_popup = "#1f2020"
          colors.bg_search = "#b4cad5"
          colors.bg_sidebar = "#1b1c1c"
          colors.bg_statusline = "#1f2020"
          colors.bg_visual = "#464747"
          colors.border = "#919091"
          colors.fg_dark = "#c7c6c7"
          colors.fg_float = "#e3e2e2"
          colors.fg_gutter = "#464747"
          colors.fg_sidebar = "#c7c6c7"
          colors.blue = "#bac9d1"
          colors.blue0 = "#3b494f"
          colors.blue1 = "#bac9d1"
          colors.blue2 = "#bac9d1"
          colors.blue5 = "#bac9d1"
          colors.blue6 = "#bac9d1"
          colors.blue7 = "#bac9d1"
          colors.cyan = "#c0c8cc"
          colors.dark3 = "#464747"
          colors.dark5 = "#464747"
          colors.error = "#ffb4ab"
          colors.green = "#b4cad5"
          colors.green1 = "#b4cad5"
          colors.green2 = "#b4cad5"
          colors.hint = "#c0c8cc"
          colors.info = "#bac9d1"
          colors.magenta = "#b4cad5"
          colors.magenta2 = "#b4cad5"
          colors.orange = "#ffb4ab"
          colors.purple = "#bac9d1"
          colors.red = "#ffb4ab"
          colors.red1 = "#ffb4ab"
          colors.teal = "#c0c8cc"
          colors.terminal_black = "#121314"
          colors.warning = "#ffb4ab"
          colors.yellow = "#c0c8cc"
        end,
      }
    end,
  }
}
