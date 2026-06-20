import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell
import qs.modules.common.functions
import qs.services as Services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: page
    forceWidth: true

    function goTo(term) {
        const t = term.toLowerCase().trim()

        function findTarget(rootItem) {
            for (let i = 0; i < rootItem.children.length; i++) {
                let child = rootItem.children[i]
                if (child.title && child.title.toLowerCase().includes(t)) {
                    return child
                }
            }
            for (let i = 0; i < rootItem.children.length; i++) {
                let found = findTarget(rootItem.children[i])
                if (found) return found
            }
            return null
        }

        let target = findTarget(contentColumn)
        if (target) {
            let pos = target.mapToItem(contentColumn, 0, 0)
            page.contentY = Math.max(0, pos.y - 0)
        }
    }

    Component.onCompleted: {
        const h = Config.options.hyprland
        Services.HyprlandConfig.set("decoration:rounding",                   h.decoration.rounding)
        Services.HyprlandConfig.set("decoration:blur:enabled",               h.decoration.blur.enabled ? 1 : 0)
        Services.HyprlandConfig.set("decoration:blur:size",                  h.decoration.blur.size)
        Services.HyprlandConfig.set("decoration:blur:passes",                h.decoration.blur.passes)
        Services.HyprlandConfig.set("decoration:active_opacity",             h.decoration.activeOpacity)
        Services.HyprlandConfig.set("decoration:inactive_opacity",           h.decoration.inactiveOpacity)
        Services.HyprlandConfig.set("general:border_size",                   h.general.borderSize)
        Services.HyprlandConfig.set("general:gaps_in",                       h.general.gapsIn)
        Services.HyprlandConfig.set("general:gaps_out",                      h.general.gapsOut)
        Services.HyprlandConfig.set("general:layout",                        h.general.layout)
        Services.HyprlandConfig.set("animations:enabled",                    h.animations.enable ? 1 : 0)
        Services.HyprlandConfig.set("input:kb_layout",                       h.input.kbLayout)
        Services.HyprlandConfig.set("input:numlock_by_default",              h.input.numlock ? 1 : 0)
        Services.HyprlandConfig.set("input:repeat_delay",                    h.input.repeatDelay)
        Services.HyprlandConfig.set("input:repeat_rate",                     h.input.repeatRate)
        Services.HyprlandConfig.set("input:follow_mouse",                    h.input.followMouse)
        Services.HyprlandConfig.set("input:touchpad:natural_scroll",         h.input.touchpad.naturalScroll ? 1 : 0)
        Services.HyprlandConfig.set("input:touchpad:disable_while_typing",   h.input.touchpad.disableWhileTyping ? 1 : 0)
        Services.HyprlandConfig.set("input:touchpad:clickfinger_behavior",   h.input.touchpad.clickfingerBehavior ? 1 : 0)
        Services.HyprlandConfig.set("input:touchpad:scroll_factor",          h.input.touchpad.scrollFactor)
    }

    // ── Layout ────────────────────────────────────────────────────────────
    ContentSection {
        icon: "auto_awesome_mosaic"
        title: Services.Translation.tr("Layout")

        ContentSubsection {
            title: Services.Translation.tr("Tiling Layout")
            ConfigSelectionArray {
                currentValue: Config.options.hyprland.general.layout
                onSelected: newValue => {
                    Config.options.hyprland.general.layout = newValue
                    Services.HyprlandConfig.set("general:layout", newValue)
                }
                options: [
                    { displayName: Services.Translation.tr("Dwindle"),   icon: "browse",             value: "dwindle"   },
                    { displayName: Services.Translation.tr("Master"),    icon: "auto_awesome_mosaic", value: "master"    },
                    { displayName: Services.Translation.tr("Scrolling"), icon: "view_carousel",       value: "scrolling" },
                ]
            }
        }
    }

    // ── Input ─────────────────────────────────────────────────────────────
    ContentSection {
        icon: "trackpad_input"
        title: Services.Translation.tr("Input")

        ContentSubsection {
            title: Services.Translation.tr("Keyboard")

            MaterialTextArea {
                id: kbLayoutTextArea
                Layout.fillWidth: true
                placeholderText: Services.Translation.tr("Keyboard layout (e.g., us, es, latam)")
                wrapMode: TextEdit.NoWrap
                Component.onCompleted: text = Config.options.hyprland.input.kbLayout
                Timer {
                    id: kbLayoutDebounceTimer
                    interval: 1000
                    running: false
                    onTriggered: {
                        Config.options.hyprland.input.kbLayout = kbLayoutTextArea.text
                        Services.HyprlandConfig.set("input:kb_layout", kbLayoutTextArea.text)
                    }
                }
                onTextChanged: kbLayoutDebounceTimer.restart()
            }

            ConfigSwitch {
                buttonIcon: "numbers"
                text: Services.Translation.tr("Numlock by default")
                checked: Config.options.hyprland.input.numlock
                onCheckedChanged: {
                    Config.options.hyprland.input.numlock = checked
                    Services.HyprlandConfig.set("input:numlock_by_default", checked ? 1 : 0)
                }
            }

            ConfigSpinBox {
                icon: "keyboard_return"
                text: Services.Translation.tr("Repeat delay (ms)")
                value: Config.options.hyprland.input.repeatDelay
                from: 100; to: 1000; stepSize: 10
                onValueChanged: {
                    Config.options.hyprland.input.repeatDelay = value
                    Services.HyprlandConfig.set("input:repeat_delay", value)
                }
            }

            ConfigSpinBox {
                icon: "speed"
                text: Services.Translation.tr("Repeat rate")
                value: Config.options.hyprland.input.repeatRate
                from: 10; to: 100; stepSize: 1
                onValueChanged: {
                    Config.options.hyprland.input.repeatRate = value
                    Services.HyprlandConfig.set("input:repeat_rate", value)
                }
            }

            ConfigSelectionArray {
                currentValue: Config.options.hyprland.input.followMouse
                onSelected: newValue => {
                    Config.options.hyprland.input.followMouse = newValue
                    Services.HyprlandConfig.set("input:follow_mouse", newValue)
                }
                options: [
                    { displayName: Services.Translation.tr("Disabled"), icon: "mouse",     value: 0 },
                    { displayName: Services.Translation.tr("Full"),     icon: "open_with",  value: 1 },
                    { displayName: Services.Translation.tr("Loose"),    icon: "drag_pan",   value: 2 },
                    { displayName: Services.Translation.tr("Explicit"), icon: "ads_click",  value: 3 },
                ]
            }
        }

        ContentSubsection {
            title: Services.Translation.tr("Touchpad")

            ConfigSwitch {
                buttonIcon: "swap_vert"
                text: Services.Translation.tr("Natural scroll")
                checked: Config.options.hyprland.input.touchpad.naturalScroll
                onCheckedChanged: {
                    Config.options.hyprland.input.touchpad.naturalScroll = checked
                    Services.HyprlandConfig.set("input:touchpad:natural_scroll", checked ? 1 : 0)
                }
            }

            ConfigSwitch {
                buttonIcon: "keyboard_hide"
                text: Services.Translation.tr("Disable while typing")
                checked: Config.options.hyprland.input.touchpad.disableWhileTyping
                onCheckedChanged: {
                    Config.options.hyprland.input.touchpad.disableWhileTyping = checked
                    Services.HyprlandConfig.set("input:touchpad:disable_while_typing", checked ? 1 : 0)
                }
            }

            ConfigSwitch {
                buttonIcon: "touch_app"
                text: Services.Translation.tr("Clickfinger behavior")
                checked: Config.options.hyprland.input.touchpad.clickfingerBehavior
                onCheckedChanged: {
                    Config.options.hyprland.input.touchpad.clickfingerBehavior = checked
                    Services.HyprlandConfig.set("input:touchpad:clickfinger_behavior", checked ? 1 : 0)
                }
            }

            ConfigSpinBox {
                icon: "swipe"
                text: Services.Translation.tr("Scroll factor")
                value: Math.round(Config.options.hyprland.input.touchpad.scrollFactor * 10)
                from: 1; to: 30; stepSize: 1
                onValueChanged: {
                    Config.options.hyprland.input.touchpad.scrollFactor = value / 10.0
                    Services.HyprlandConfig.set("input:touchpad:scroll_factor", value / 10.0)
                }
            }
        }
    }

    // ── Visual & Aesthetics ───────────────────────────────────────────────
    ContentSection {
        icon: "deblur"
        title: Services.Translation.tr("Visual & Aesthetics")

        ConfigSpinBox {
            icon: "rounded_corner"
            text: Services.Translation.tr("Window Rounding")
            value: Config.options.hyprland.decoration.rounding
            from: 0; to: 30; stepSize: 1
            onValueChanged: {
                Config.options.hyprland.decoration.rounding = value
                Services.HyprlandConfig.set("decoration:rounding", value)
            }
        }

        ConfigSwitch {
            buttonIcon: "blur_on"
            text: Services.Translation.tr("Blur")
            checked: Config.options.hyprland.decoration.blur.enabled
            onCheckedChanged: {
                Config.options.hyprland.decoration.blur.enabled = checked
                Services.HyprlandConfig.set("decoration:blur:enabled", checked ? 1 : 0)
            }
        }

        ConfigSpinBox {
            icon: "blur_circular"
            text: Services.Translation.tr("Blur Size")
            value: Config.options.hyprland.decoration.blur.size
            from: 1; to: 20; stepSize: 1
            onValueChanged: {
                Config.options.hyprland.decoration.blur.size = value
                Services.HyprlandConfig.set("decoration:blur:size", value)
            }
        }

        ConfigSpinBox {
            icon: "layers"
            text: Services.Translation.tr("Blur Passes")
            value: Config.options.hyprland.decoration.blur.passes
            from: 1; to: 6; stepSize: 1
            onValueChanged: {
                Config.options.hyprland.decoration.blur.passes = value
                Services.HyprlandConfig.set("decoration:blur:passes", value)
            }
        }

        ConfigSpinBox {
            icon: "border_outer"
            text: Services.Translation.tr("Border Size")
            value: Config.options.hyprland.general.borderSize
            from: 0; to: 10; stepSize: 1
            onValueChanged: {
                Config.options.hyprland.general.borderSize = value
                Services.HyprlandConfig.set("general:border_size", value)
            }
        }

        ConfigSpinBox {
            icon: "margin"
            text: Services.Translation.tr("Gaps In")
            value: Config.options.hyprland.general.gapsIn
            from: 0; to: 40; stepSize: 1
            onValueChanged: {
                Config.options.hyprland.general.gapsIn = value
                Services.HyprlandConfig.set("general:gaps_in", value)
            }
        }

        ConfigSpinBox {
            icon: "open_in_full"
            text: Services.Translation.tr("Gaps Out")
            value: Config.options.hyprland.general.gapsOut
            from: 0; to: 60; stepSize: 1
            onValueChanged: {
                Config.options.hyprland.general.gapsOut = value
                Services.HyprlandConfig.set("general:gaps_out", value)
            }
        }

        ConfigSpinBox {
            icon: "opacity"
            text: Services.Translation.tr("Active Opacity")
            value: Math.round(Config.options.hyprland.decoration.activeOpacity * 100)
            from: 10; to: 100; stepSize: 1
            onValueChanged: {
                Config.options.hyprland.decoration.activeOpacity = value / 100.0
                Services.HyprlandConfig.set("decoration:active_opacity", value / 100.0)
            }
        }

        ConfigSpinBox {
            icon: "opacity"
            text: Services.Translation.tr("Inactive Opacity")
            value: Math.round(Config.options.hyprland.decoration.inactiveOpacity * 100)
            from: 10; to: 100; stepSize: 1
            onValueChanged: {
                Config.options.hyprland.decoration.inactiveOpacity = value / 100.0
                Services.HyprlandConfig.set("decoration:inactive_opacity", value / 100.0)
            }
        }
    }

    // ── Animations ────────────────────────────────────────────────────────
    ContentSection {
        icon: "animation"
        title: Services.Translation.tr("Animations")

        ConfigSwitch {
            buttonIcon: "check"
            text: Services.Translation.tr("Enable Animations")
            checked: Config.options.hyprland.animations.enable
            onCheckedChanged: {
                Config.options.hyprland.animations.enable = checked
                Services.HyprlandConfig.set("animations:enabled", checked ? 1 : 0)
            }
        }

        ContentSubsection {
            title: Services.Translation.tr("Animation Preset")

            ConfigSelectionArray {
                currentValue: Config.options.hyprland.animations.animation
                onSelected: newValue => {
                    Config.options.hyprland.animations.animation = newValue
                    saveAnimProc.command = [
                        "python3",
                        Services.HyprlandConfig.configuratorScriptPath,
                        "--anim-preset", newValue
                    ]
                    saveAnimProc.running = true
                }
                options: [
                    { displayName: Services.Translation.tr("Elastic"),   icon: "move_selection_right", value: "fast"   },
                    { displayName: Services.Translation.tr("Normal"),    icon: "animation",            value: "normal" },
                    { displayName: Services.Translation.tr("Niri Like"), icon: "mobiledata_arrows",    value: "niri"   },
                ]
            }
        }

        NoticeBox {
            Layout.fillWidth: true
            Layout.topMargin: 15
            text: Services.Translation.tr("Animation presets require a require line in your hyprland.lua. Add the following line to enable presets:") + '\n\nrequire("hyprland/shellOverrides/animations")'

            Item { Layout.fillWidth: true }

            RippleButtonWithIcon {
                id: copySourceButton
                property bool justCopied: false
                Layout.fillWidth: false
                buttonRadius: Appearance.rounding.small
                materialIcon: justCopied ? "check" : "content_copy"
                mainText: justCopied ? Services.Translation.tr("Copied!") : Services.Translation.tr("Copy line")
                onClicked: {
                    copySourceButton.justCopied = true
                    Quickshell.clipboardText = 'require("hyprland/shellOverrides/animations")'
                    revertSourceTimer.restart()
                }
                colBackground: ColorUtils.transparentize(Appearance.colors.colPrimaryContainer)
                colBackgroundHover: Appearance.colors.colPrimaryContainerHover
                colRipple: Appearance.colors.colPrimaryContainerActive
                Timer {
                    id: revertSourceTimer
                    interval: 1500
                    onTriggered: copySourceButton.justCopied = false
                }
            }
        }

        Process {
            id: saveAnimProc
            onRunningChanged: if (!running) reloadAnimProc.running = true
        }
        Process {
            id: reloadAnimProc
            command: ["hyprctl", "reload"]
        }
    }
}