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
          colors.bg = "{{colors.surface.default.hex}}"
          colors.fg = "{{colors.on_surface.default.hex}}"
          colors.bg_dark = "{{colors.surface_variant.default.hex}}"
          colors.bg_float = "{{colors.surface.default.hex}}"
          colors.bg_highlight = "{{colors.surface_container_highest.default.hex}}"
          colors.bg_popup = "{{colors.surface_container.default.hex}}"
          colors.bg_search = "{{colors.tertiary.default.hex}}"
          colors.bg_sidebar = "{{colors.surface_container_low.default.hex}}"
          colors.bg_statusline = "{{colors.surface_container.default.hex}}"
          colors.bg_visual = "{{colors.surface_variant.default.hex}}"
          colors.border = "{{colors.outline.default.hex}}"
          colors.fg_dark = "{{colors.on_surface_variant.default.hex}}"
          colors.fg_float = "{{colors.on_surface.default.hex}}"
          colors.fg_gutter = "{{colors.outline_variant.default.hex}}"
          colors.fg_sidebar = "{{colors.on_surface_variant.default.hex}}"
          colors.blue = "{{colors.primary.default.hex}}"
          colors.blue0 = "{{colors.primary_container.default.hex}}"
          colors.blue1 = "{{colors.primary.default.hex}}"
          colors.blue2 = "{{colors.primary.default.hex}}"
          colors.blue5 = "{{colors.primary.default.hex}}"
          colors.blue6 = "{{colors.primary.default.hex}}"
          colors.blue7 = "{{colors.primary.default.hex}}"
          colors.cyan = "{{colors.secondary.default.hex}}"
          colors.dark3 = "{{colors.surface_variant.default.hex}}"
          colors.dark5 = "{{colors.surface_variant.default.hex}}"
          colors.error = "{{colors.error.default.hex}}"
          colors.green = "{{colors.tertiary.default.hex}}"
          colors.green1 = "{{colors.tertiary.default.hex}}"
          colors.green2 = "{{colors.tertiary.default.hex}}"
          colors.hint = "{{colors.secondary.default.hex}}"
          colors.info = "{{colors.primary.default.hex}}"
          colors.magenta = "{{colors.tertiary.default.hex}}"
          colors.magenta2 = "{{colors.tertiary.default.hex}}"
          colors.orange = "{{colors.error.default.hex}}"
          colors.purple = "{{colors.primary.default.hex}}"
          colors.red = "{{colors.error.default.hex}}"
          colors.red1 = "{{colors.error.default.hex}}"
          colors.teal = "{{colors.secondary.default.hex}}"
          colors.terminal_black = "{{colors.surface.default.hex}}"
          colors.warning = "{{colors.error.default.hex}}"
          colors.yellow = "{{colors.secondary.default.hex}}"
        end,
      }
    end,
  }
}
