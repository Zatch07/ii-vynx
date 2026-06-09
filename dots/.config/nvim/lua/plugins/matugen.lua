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
          colors.bg = "#10131c"
          colors.fg = "#e0e2ef"
          colors.bg_dark = "#404659"
          colors.bg_float = "#10131c"
          colors.bg_highlight = "#31343f"
          colors.bg_popup = "#1c1f29"
          colors.bg_search = "#b1c5ff"
          colors.bg_sidebar = "#181b25"
          colors.bg_statusline = "#1c1f29"
          colors.bg_visual = "#404659"
          colors.border = "#8a90a5"
          colors.fg_dark = "#c0c6dc"
          colors.fg_float = "#e0e2ef"
          colors.fg_gutter = "#404659"
          colors.fg_sidebar = "#c0c6dc"
          colors.blue = "#58d6f7"
          colors.blue0 = "#004e5e"
          colors.blue1 = "#58d6f7"
          colors.blue2 = "#58d6f7"
          colors.blue5 = "#58d6f7"
          colors.blue6 = "#58d6f7"
          colors.blue7 = "#58d6f7"
          colors.cyan = "#86d1e9"
          colors.dark3 = "#404659"
          colors.dark5 = "#404659"
          colors.error = "#ffb4ab"
          colors.green = "#b1c5ff"
          colors.green1 = "#b1c5ff"
          colors.green2 = "#b1c5ff"
          colors.hint = "#86d1e9"
          colors.info = "#58d6f7"
          colors.magenta = "#b1c5ff"
          colors.magenta2 = "#b1c5ff"
          colors.orange = "#ffb4ab"
          colors.purple = "#58d6f7"
          colors.red = "#ffb4ab"
          colors.red1 = "#ffb4ab"
          colors.teal = "#86d1e9"
          colors.terminal_black = "#10131c"
          colors.warning = "#ffb4ab"
          colors.yellow = "#86d1e9"
        end,
      }
    end,
  }
}
