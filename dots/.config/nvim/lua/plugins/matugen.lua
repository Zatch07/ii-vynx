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
          colors.bg = "#19120d"
          colors.fg = "#f0dfd7"
          colors.bg_dark = "#52443c"
          colors.bg_float = "#19120d"
          colors.bg_highlight = "#3d332d"
          colors.bg_popup = "#261e19"
          colors.bg_search = "#c9ca93"
          colors.bg_sidebar = "#221a15"
          colors.bg_statusline = "#261e19"
          colors.bg_visual = "#52443c"
          colors.border = "#9f8d83"
          colors.fg_dark = "#d7c3b8"
          colors.fg_float = "#f0dfd7"
          colors.fg_gutter = "#52443c"
          colors.fg_sidebar = "#d7c3b8"
          colors.blue = "#ffb787"
          colors.blue0 = "#6e390e"
          colors.blue1 = "#ffb787"
          colors.blue2 = "#ffb787"
          colors.blue5 = "#ffb787"
          colors.blue6 = "#ffb787"
          colors.blue7 = "#ffb787"
          colors.cyan = "#e5bfa8"
          colors.dark3 = "#52443c"
          colors.dark5 = "#52443c"
          colors.error = "#ffb4ab"
          colors.green = "#c9ca93"
          colors.green1 = "#c9ca93"
          colors.green2 = "#c9ca93"
          colors.hint = "#e5bfa8"
          colors.info = "#ffb787"
          colors.magenta = "#c9ca93"
          colors.magenta2 = "#c9ca93"
          colors.orange = "#ffb4ab"
          colors.purple = "#ffb787"
          colors.red = "#ffb4ab"
          colors.red1 = "#ffb4ab"
          colors.teal = "#e5bfa8"
          colors.terminal_black = "#19120d"
          colors.warning = "#ffb4ab"
          colors.yellow = "#e5bfa8"
        end,
      }
    end,
  }
}
