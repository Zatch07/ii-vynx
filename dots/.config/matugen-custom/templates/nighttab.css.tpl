:root {
  /* BACKGROUNDS - Using Matugen Surface Shades */
  --theme-background-theme: {{colors.surface_container_lowest.default.hex}} !important;
  --theme-background-color: {{colors.surface.default.hex}} !important;

  /* ELEMENT BOXES - Darker/Distinguishable Containers */
  --theme-primary-010: {{colors.surface_container_lowest.default.hex}} !important;
  --theme-primary-020: {{colors.surface_container_low.default.hex}} !important;
  --theme-primary-030: {{colors.surface_container.default.hex}} !important;
  --theme-primary-040: {{colors.surface_container_high.default.hex}} !important;
  --theme-primary-050: {{colors.surface_container_highest.default.hex}} !important;

  /* TEXT - Dynamic Contrast */
  --theme-primary-text-010: {{colors.on_surface.default.hex}} !important;
  --theme-primary-text-020: {{colors.on_surface_variant.default.hex}} !important;
  --theme-primary-text-030: {{colors.outline.default.hex}} !important;

  /* ACCENT - For Icons & Active Elements */
  --theme-accent: {{colors.primary.default.hex}} !important;
  --theme-accent-text: {{colors.on_primary.default.hex}} !important;

  /* ICON & FORM OVERRIDES */
  --form-icon: {{colors.primary.default.hex}} !important;
  --form-icon-checked: {{colors.primary.default.hex}} !important;
  --icon-color: {{colors.primary.default.hex}} !important;
  --form-icon-symbol: {{colors.on_primary.default.hex}} !important;
  --form-group-border: {{colors.outline_variant.default.hex}} !important;

  /* MISC UI Polish */
  --theme-shadow: {{colors.shadow.default.hex}} !important;
  --theme-shade-opacity: 60 !important;
  --theme-shade-blur: 8 !important;
  --theme-radius: 12 !important; /* Consistent rounding */
}

/* Specific fix for Bookmark Box Backgrounds to make them pop */
.bookmark-item {
  background-color: var(--theme-primary-020) !important;
  border: 1px solid var(--theme-primary-030) !important;
  box-shadow: 0 4px 6px -1px var(--theme-shadow), 0 2px 4px -1px var(--theme-shadow) !important;
}

.bookmark-item:hover {
  background-color: var(--theme-primary-030) !important;
  border-color: var(--theme-accent) !important;
}
