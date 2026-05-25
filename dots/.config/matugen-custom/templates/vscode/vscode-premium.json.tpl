{
    "editor.fontLigatures": true,
    "editor.fontSize": 18,
    "editor.fontWeight": "normal",
    "security.workspace.trust.untrustedFiles": "open",
    "workbench.iconTheme": "material-icon-theme",
    "files.autoSave": "afterDelay",
    "workbench.startupEditor": "none",
    "editor.inlineSuggest.enabled": true,
    "editor.fontFamily": "Cartograph CF",
    "workbench.colorTheme": "Matugen Dynamic Theme",



    /* 🎨 THE MATUGEN COLOR KEY (ALL SLOTS) 🎨
       Contrast Levels (Backgrounds):
       - DEEPEST: {{colors.surface_container_lowest.dark.hex}}
       - LOW:     {{colors.surface_container_low.dark.hex}}
       - NORMAL:  {{colors.surface_container.dark.hex}}
       - HIGH:    {{colors.surface_container_high.dark.hex}}
       - HIGHEST: {{colors.surface_container_highest.dark.hex}}
       
       Hue Categories (Accents):
       - PRIMARY: {{colors.primary.dark.hex}}        (Main Theme)
       - SECONDARY: {{colors.secondary.dark.hex}}    (Sub-Accents)
       - TERTIARY: {{colors.tertiary.dark.hex}}      (Pop of color)
    */




    "workbench.colorCustomizations": {
        // --- BASE & WINDOW ---
        "focusBorder":                            "{{colors.primary.dark.hex}}55",
        "foreground":                             "{{colors.on_surface.dark.hex}}",
        "widget.shadow":                          "#000000AA",
        "selection.background":                   "{{colors.primary.dark.hex}}33",
        "descriptionForeground":                  "{{colors.on_surface_variant.dark.hex}}AA",
        "errorForeground":                        "{{colors.error.dark.hex}}",
        
        "window.activeBorder":                    "{{colors.primary.dark.hex}}33",
        "window.inactiveBorder":                  "#00000000",
        
        // --- TEXT ---
        "textLink.foreground":                    "{{colors.primary.dark.hex}}",
        "textLink.activeForeground":              "{{colors.primary_fixed.dark.hex}}",
        "textCodeBlock.background":               "{{colors.surface_container_low.dark.hex}}",

        // --- BUTTONS & INPUT ---
        "button.background":                      "{{colors.primary.dark.hex}}",
        "button.foreground":                      "{{colors.on_primary.dark.hex}}",
        "button.hoverBackground":                 "{{colors.primary_container.dark.hex}}",

        "input.background":                       "{{colors.surface_container_high.dark.hex}}55",
        "input.foreground":                       "{{colors.on_surface.dark.hex}}",
        "input.border":                           "{{colors.outline_variant.dark.hex}}33",

        // --- SCROLLBAR ---
        "scrollbarSlider.background":             "{{colors.primary.dark.hex}}11",
        "scrollbarSlider.hoverBackground":        "{{colors.primary.dark.hex}}22",
        "scrollbarSlider.activeBackground":       "{{colors.primary.dark.hex}}44",

        // --- ACTIVITY BAR (The Tinted Sidebar) ---
        "activityBar.background":                 "#0a0a0a",
        "activityBar.foreground":                 "{{colors.primary.dark.hex}}",
        "activityBar.inactiveForeground":         "{{colors.on_surface_variant.dark.hex}}66",
        "activityBar.border":                     "#00000000",
        "activityBar.activeBorder":               "{{colors.primary.dark.hex}}",
        "activityBarBadge.background":            "{{colors.primary.dark.hex}}",
        "activityBarBadge.foreground":            "{{colors.on_primary.dark.hex}}",

        // --- SIDE BAR ---
        "sideBar.background":                     "{{colors.surface_container_lowest.dark.hex}}CC",
        "sideBar.foreground":                     "{{colors.on_surface.dark.hex}}CC",
        "sideBar.border":                         "#00000000",
        "sideBarTitle.foreground":                "{{colors.primary.dark.hex}}BB",
        "sideBarSectionHeader.background":        "#00000000",
        "sideBarSectionHeader.foreground":        "{{colors.on_surface.dark.hex}}",
        "sideBarSectionHeader.border":            "#00000000",

        // --- EDITOR & TABS ---
        "editorGroup.border":                     "{{colors.outline_variant.dark.hex}}11",
        "editorGroupHeader.tabsBackground":       "#0a0a0a",
        "editorGroupHeader.tabsBorder":           "#00000000",
        
        "tab.activeBackground":                   "#121212",
        "tab.activeForeground":                   "{{colors.primary.dark.hex}}",
        "tab.activeBorderTop":                    "{{colors.primary.dark.hex}}",
        "tab.inactiveBackground":                 "#0a0a0a",
        "tab.inactiveForeground":                 "{{colors.on_surface_variant.dark.hex}}88",
        "tab.border":                             "#00000000",

        "editor.background":                      "{{colors.surface_container_lowest.dark.hex}}CC",
        "editor.foreground":                      "{{colors.on_surface.dark.hex}}CC",
        "editorLineNumber.foreground":            "{{colors.on_surface_variant.dark.hex}}44",
        "editorLineNumber.activeForeground":      "{{colors.primary.dark.hex}}",
        "editorCursor.foreground":                "{{colors.primary.dark.hex}}",
        "editor.selectionBackground":             "{{colors.primary.dark.hex}}33",
        "editor.lineHighlightBackground":         "{{colors.primary.dark.hex}}15",
        "editor.lineHighlightBorder":             "#00000000",

        "editorGutter.background":                "#0f0f0f",
        "editorBracketHighlight.foreground1":     "{{colors.primary.dark.hex}}",
        "editorBracketHighlight.foreground2":     "{{colors.secondary.dark.hex}}",
        "editorBracketHighlight.foreground3":     "{{colors.tertiary.dark.hex}}",

        // --- PANEL & STATUS BAR ---
        "panel.background":                       "#0a0a0a",
        "panel.border":                           "{{colors.outline_variant.dark.hex}}22",
        "panelTitle.activeForeground":            "{{colors.primary.dark.hex}}",
        "panelTitle.activeBorder":                "{{colors.primary.dark.hex}}",

        "statusBar.background":                   "{{colors.primary.dark.hex}}",
        "statusBar.foreground":                   "{{colors.on_primary.dark.hex}}",
        "statusBar.border":                       "{{colors.primary_container.dark.hex}}",
        "statusBar.noFolderBackground":           "{{colors.primary.dark.hex}}",

        "titleBar.activeBackground":              "#050505",
        "titleBar.activeForeground":              "{{colors.on_surface.dark.hex}}",
        "titleBar.border":                        "#00000000"
    },

    "editor.tokenColorCustomizations": {
        "textMateRules": [
            {
                "scope": ["comment", "punctuation.definition.comment"],
                "settings": { "foreground": "{{colors.on_surface_variant.dark.hex}}77", "fontStyle": "italic" }
            },
            {
                "scope": ["keyword", "storage.type", "storage.modifier"],
                "settings": { "foreground": "{{colors.primary.dark.hex}}", "fontStyle": "italic" }
            },
            {
                "scope": ["string", "constant.other.symbol", "punctuation.definition.string"],
                "settings": { "foreground": "{{colors.secondary.dark.hex}}" }
            },
            {
                "scope": ["entity.name.function", "support.function"],
                "settings": { "foreground": "{{colors.tertiary.dark.hex}}" }
            },
            {
                "scope": ["variable", "support.variable"],
                "settings": { "foreground": "{{colors.on_surface.dark.hex}}" }
            },
            {
                "scope": ["entity.name.type", "entity.name.class", "support.type", "support.class"],
                "settings": { "foreground": "{{colors.primary.dark.hex}}BB" }
            },
            {
                "scope": ["constant.numeric", "constant.language"],
                "settings": { "foreground": "{{colors.secondary.dark.hex}}AA" }
            }
        ]
    }
}
