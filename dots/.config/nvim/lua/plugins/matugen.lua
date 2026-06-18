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
          colors.bg = "#1c1015"
          colors.fg = "#f4dde5"
          colors.bg_dark = "#59404b"
          colors.bg_float = "#1c1015"
          colors.bg_highlight = "#3f3137"
          colors.bg_popup = "#291c22"
          colors.bg_search = "#fdb0d5"
          colors.bg_sidebar = "#24181e"
          colors.bg_statusline = "#291c22"
          colors.bg_visual = "#59404b"
          colors.border = "#a78895"
          colors.fg_dark = "#e0bdcb"
          colors.fg_float = "#f4dde5"
          colors.fg_gutter = "#59404b"
          colors.fg_sidebar = "#e0bdcb"
          colors.blue = "#d1bcff"
          colors.blue0 = "#50378a"
          colors.blue1 = "#d1bcff"
          colors.blue2 = "#d1bcff"
          colors.blue5 = "#d1bcff"
          colors.blue6 = "#d1bcff"
          colors.blue7 = "#d1bcff"
          colors.cyan = "#d0bcfe"
          colors.dark3 = "#59404b"
          colors.dark5 = "#59404b"
          colors.error = "#ffb4ab"
          colors.green = "#fdb0d5"
          colors.green1 = "#fdb0d5"
          colors.green2 = "#fdb0d5"
          colors.hint = "#d0bcfe"
          colors.info = "#d1bcff"
          colors.magenta = "#fdb0d5"
          colors.magenta2 = "#fdb0d5"
          colors.orange = "#ffb4ab"
          colors.purple = "#d1bcff"
          colors.red = "#ffb4ab"
          colors.red1 = "#ffb4ab"
          colors.teal = "#d0bcfe"
          colors.terminal_black = "#1c1015"
          colors.warning = "#ffb4ab"
          colors.yellow = "#d0bcfe"
        end,
      }
    end,
  }
}
