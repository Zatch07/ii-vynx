import QtQuick
import Quickshell
import Quickshell.Io

// Dynamic Material Design 3 color palette.
// Reads matugen-generated colors.json from the end-4 quickshell state directory
// and watches for live changes (wallpaper-driven reloads).
QtObject {
    id: colors

    // Point directly at the matugen output used by end-4
    property string colorFilePath: Quickshell.env("HOME")
        + "/.local/state/quickshell/user/generated/colors.json"

    property var colorFileView: FileView {
        path: colors.colorFilePath
        watchChanges: true
        preload: true
        onFileChanged: reload()
        onLoaded: colors._applyColors()
    }

    // Map matugen snake_case keys → skwd camelCase properties
    function _applyColors() {
        var text = colorFileView.text().trim()
        if (!text || text === "{}") return
        try {
            var d = JSON.parse(text)
            colors.primary           = d.primary             ?? colors.primary
            colors.primaryText       = d.on_primary          ?? colors.primaryText
            colors.primaryContainer  = d.primary_container   ?? colors.primaryContainer
            colors.primaryContainerText = d.on_primary_container ?? colors.primaryContainerText
            colors.primaryForeground = d.on_primary          ?? colors.primaryForeground
            colors.secondary         = d.secondary           ?? colors.secondary
            colors.secondaryText     = d.on_secondary        ?? colors.secondaryText
            colors.secondaryContainer = d.secondary_container ?? colors.secondaryContainer
            colors.secondaryContainerText = d.on_secondary_container ?? colors.secondaryContainerText
            colors.tertiary          = d.tertiary            ?? colors.tertiary
            colors.tertiaryText      = d.on_tertiary         ?? colors.tertiaryText
            colors.tertiaryContainer = d.tertiary_container  ?? colors.tertiaryContainer
            colors.tertiaryContainerText = d.on_tertiary_container ?? colors.tertiaryContainerText
            colors.background        = d.background          ?? colors.background
            colors.backgroundText    = d.on_background       ?? colors.backgroundText
            colors.surface           = d.surface             ?? colors.surface
            colors.surfaceText       = d.on_surface          ?? colors.surfaceText
            colors.surfaceVariant    = d.surface_variant     ?? colors.surfaceVariant
            colors.surfaceVariantText = d.on_surface_variant ?? colors.surfaceVariantText
            colors.surfaceContainer  = d.surface_container   ?? colors.surfaceContainer
            colors.error             = d.error               ?? colors.error
            colors.errorText         = d.on_error            ?? colors.errorText
            colors.errorContainer    = d.error_container     ?? colors.errorContainer
            colors.errorContainerText = d.on_error_container ?? colors.errorContainerText
            colors.outline           = d.outline             ?? colors.outline
            colors.shadow            = d.shadow              ?? colors.shadow
            colors.inverseSurface    = d.inverse_surface     ?? colors.inverseSurface
            colors.inverseSurfaceText = d.inverse_on_surface ?? colors.inverseSurfaceText
            colors.inversePrimary    = d.inverse_primary     ?? colors.inversePrimary
            console.log("Colors: Loaded matugen colors from", colors.colorFilePath)
        } catch (e) {
            console.log("Colors: Error parsing colors.json:", e)
        }
    }


    // Color properties (Material Design 3 scheme) — defaults used until matugen loads
    // Primary
    property color primary: "#bfce7f"
    property color primaryText: "#2b3400"
    property color primaryContainer: "#404c09"
    property color primaryContainerText: "#dbea98"
    property color primaryForeground: "#2b3400"

    // Secondary
    property color secondary: "#c5c9a8"
    property color secondaryText: "#2e331b"
    property color secondaryContainer: "#444930"
    property color secondaryContainerText: "#e1e6c3"

    // Tertiary
    property color tertiary: "#a1d0c4"
    property color tertiaryText: "#04372f"
    property color tertiaryContainer: "#214e45"
    property color tertiaryContainerText: "#bdece0"

    // Background & Surface
    property color background: "#13140d"
    property color backgroundText: "#e4e3d7"
    property color surface: "#13140d"
    property color surfaceText: "#e4e3d7"
    property color surfaceVariant: "#46483c"
    property color surfaceVariantText: "#c7c8b7"
    property color surfaceContainer: "#1f2019"

    // Error
    property color error: "#ffb4ab"
    property color errorText: "#690005"
    property color errorContainer: "#93000a"
    property color errorContainerText: "#ffdad6"

    // Utility
    property color outline: "#919283"
    property color shadow: "#000000"
    property color inverseSurface: "#e4e3d7"
    property color inverseSurfaceText: "#303129"
    property color inversePrimary: "#576421"
}
