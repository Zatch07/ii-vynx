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
          colors.bg = "#0a1519"
          colors.fg = "#d9e4eb"
          colors.bg_dark = "#354a53"
          colors.bg_float = "#0a1519"
          colors.bg_highlight = "#2c363b"
          colors.bg_popup = "#172126"
          colors.bg_search = "#8ad0ee"
          colors.bg_sidebar = "#121d22"
          colors.bg_statusline = "#172126"
          colors.bg_visual = "#354a53"
          colors.border = "#7e949f"
          colors.fg_dark = "#b4cad5"
          colors.fg_float = "#d9e4eb"
          colors.fg_gutter = "#354a53"
          colors.fg_sidebar = "#b4cad5"
          colors.blue = "#5ddbbc"
          colors.blue0 = "#005142"
          colors.blue1 = "#5ddbbc"
          colors.blue2 = "#5ddbbc"
          colors.blue5 = "#5ddbbc"
          colors.blue6 = "#5ddbbc"
          colors.blue7 = "#5ddbbc"
          colors.cyan = "#86d6bf"
          colors.dark3 = "#354a53"
          colors.dark5 = "#354a53"
          colors.error = "#ffb4ab"
          colors.green = "#8ad0ee"
          colors.green1 = "#8ad0ee"
          colors.green2 = "#8ad0ee"
          colors.hint = "#86d6bf"
          colors.info = "#5ddbbc"
          colors.magenta = "#8ad0ee"
          colors.magenta2 = "#8ad0ee"
          colors.orange = "#ffb4ab"
          colors.purple = "#5ddbbc"
          colors.red = "#ffb4ab"
          colors.red1 = "#ffb4ab"
          colors.teal = "#86d6bf"
          colors.terminal_black = "#0a1519"
          colors.warning = "#ffb4ab"
          colors.yellow = "#86d6bf"
        end,
      }
    end,
  }
}
