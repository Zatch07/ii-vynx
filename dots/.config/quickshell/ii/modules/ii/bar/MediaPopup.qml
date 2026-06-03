import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import "./cards"
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects

StyledPopup {
    id: root
    popupRadius: Appearance.rounding.large

    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property string cleanedTitle: StringUtils.cleanMusicTitle(activePlayer?.trackTitle) || Translation.tr("No media")

    animate: false // We have to disable the animation if we have only one card
    contentItem: ColumnLayout {
        spacing: 12

        HeroCard {
            id: mediaHero
            compactMode: true
            adaptiveWidth: true
            Layout.fillWidth: true
            icon: "music_note"

            title: activePlayer?.trackArtist || Translation.tr("Unknown Artist")
            subtitle: activePlayer ? activePlayer.trackTitle : Translation.tr("No media")

            pillText: activePlayer ? (activePlayer.playbackState == MprisPlaybackState.Playing ? Translation.tr("Playing") : Translation.tr("Paused")) : ""
            pillIcon: activePlayer ? (activePlayer.playbackState == MprisPlaybackState.Playing ? "play_arrow" : "pause") : ""
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: lyricScroller.height + 24
            visible: LyricsService.hasSyncedLines
            radius: Appearance.rounding.normal
            color: Appearance.colors.colSurfaceContainerHigh

            LyricScroller {
                id: lyricScroller
                anchors.centerIn: parent
                width: parent.width - 24
                height: (halfVisibleLines * 2 + 1) * rowHeight
                
                defaultLyricsSize: Appearance.font.pixelSize.small
                useGradientMask: true
                halfVisibleLines: 2
                downScale: 0.9
                rowHeight: 24
                gradientDensity: 0.25
            }
        }
    }
}
