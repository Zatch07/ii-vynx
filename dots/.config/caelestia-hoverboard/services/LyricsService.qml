pragma Singleton

import "../utils/scripts/lrcparser.js" as Lrc
import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia
import Caelestia.Config
import qs.utils

Singleton {
    id: root

    property var player: Players.active
    onPlayerChanged: {
        loadLyrics();
    }
    property int currentIndex: -1
    property bool loading: false
    property bool isManualSeeking: false
    property bool lyricsVisible: GlobalConfig.services.showLyrics
    property string backend: "Local"
    property string preferredBackend: GlobalConfig.services.lyricsBackend
    property real currentSongId: 0
    property string loadedLocalFile: ""
    property real offset
    property int currentRequestId: 0
    property var lyricsMap: ({})

    readonly property string lyricsDir: Paths.absolutePath(GlobalConfig.paths.lyricsDir)
    readonly property string lyricsMapFile: lyricsDir + "/lyrics_map.json"
    readonly property alias model: lyricsModel
    readonly property alias candidatesModel: fetchedCandidatesModel
    readonly property var _netEaseHeaders: ({
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0",
            "Referer": "https://music.163.com/"
        })

    function getMetadata() {
        if (!player || !player.metadata)
            return null;
        let artist = player.metadata["xesam:artist"];
        let title = player.metadata["xesam:title"];
        
        if (artist !== undefined && artist !== null) {
            if (typeof artist === "object") {
                let temp = [];
                for (let i = 0; i < artist.length; i++) {
                    temp.push(artist[i]);
                }
                artist = temp.join(", ");
            } else {
                artist = String(artist);
            }
        }
        
        return {
            artist: artist || "Unknown",
            title: title ? String(title) : "Unknown"
        };
    }

    function _metaKey(meta) {
        return `${meta.artist} - ${meta.title}`;
    }

    function savePrefs() {
        let meta = getMetadata();
        if (!meta)
            return;
        let key = _metaKey(meta);
        let existing = root.lyricsMap[key] ?? {};
        root.lyricsMap[key] = {
            offset: root.offset,
            backend: root.backend,
            neteaseId: existing.neteaseId ?? null
        };
        // reassign to notify QML bindings of the map change
        root.lyricsMap = root.lyricsMap;
        saveLyricsMap.command = ["sh", "-c", `mkdir -p "${root.lyricsDir}" && echo '${JSON.stringify(root.lyricsMap).replace(/'/g, "'\\''")}' > "${root.lyricsMapFile}"`];
        saveLyricsMap.running = true;
    }

    function toggleVisibility() {
        GlobalConfig.services.showLyrics = !GlobalConfig.services.showLyrics;
    }

    function cleanMusicTitle(title) {
        if (!title) return "";
        // Brackets
        title = title.replace(/^ *\([^)]*\) */g, " "); // Round brackets
        title = title.replace(/^ *\[[^\]]*\] */g, " "); // Square brackets
        title = title.replace(/^ *\{[^\}]*\} */g, " "); // Curly brackets
        // Japanese brackets
        title = title.replace(/^ *【[^】]*】/, ""); 
        title = title.replace(/^ *《[^》]*》/, ""); 
        title = title.replace(/^ *「[^」]*」/, ""); 
        title = title.replace(/^ *『[^』]*』/, ""); 

        return title.trim();
    }

    function normalizeTitle(rawTitle) {
        if (!rawTitle) return "";
        let cleaned = cleanMusicTitle(rawTitle);
        const parts = cleaned.split(" - ");
        let main = parts[0].trim();
        let suffix = parts.slice(1).join(" - ").trim();
        if (suffix && /\b(remix|version|edit|mix|rework)\b/i.test(suffix))
            cleaned = `${main} ${suffix}`;
        else
            cleaned = main;
        cleaned = cleaned.replace(/\s*[\(\[\{]([^\)\]\}]*)[\)\]\}]\s*/g, function(_, inner) {
            if (/(?:feat\.?|ft\.?|featuring)/i.test(inner)) {
                const m = inner.replace(/^(?:feat\.?|ft\.?|featuring)\s*/i, '').trim();
                return m ? ` feat. ${m} ` : ' ';
            }
            return ' ';
        }).replace(/\s+/g, " ").trim();
        return cleaned;
    }

    function normalizeArtist(rawArtist) {
        if (!rawArtist) return "";
        let cleaned = rawArtist.trim();
        cleaned = cleaned.split(",")[0];
        cleaned = cleaned.split(/ feat\.? /i)[0];
        cleaned = cleaned.split(/ ft\.? /i)[0];
        cleaned = cleaned.split(/ featuring /i)[0];
        cleaned = cleaned.split(/ & /)[0];
        cleaned = cleaned.split(/ x /i)[0];
        return cleaned.trim();
    }

    function loadLyrics() {
        loadDebounce.restart();
    }

    function _doLoadLyrics() {
        const meta = getMetadata();
        if (!meta) {
            lyricsModel.clear();
            root.currentIndex = -1;
            return;
        }

        loading = true;
        lyricsModel.clear();
        currentIndex = -1;

        root.currentRequestId++;
        let requestId = root.currentRequestId;

        let title = meta.title || "";
        let artist = meta.artist || "";
        let duration = Math.round(player?.length ?? 0);

        let normTitle = normalizeTitle(title);
        let normArtist = normalizeArtist(artist);

        fetchAttempt(requestId, normTitle, normArtist, duration, 0);
    }

    function fetchAttempt(reqId, title, artist, duration, attempt) {
        if (reqId !== root.currentRequestId) return;

        let url = "";
        if (attempt === 0) {
            url = `https://lrclib.net/api/get?track_name=${encodeURIComponent(title)}&artist_name=${encodeURIComponent(artist)}`;
            if (duration > 0) url += `&duration=${duration}`;
        } else if (attempt === 1) {
            url = `https://lrclib.net/api/search?track_name=${encodeURIComponent(title)}&artist_name=${encodeURIComponent(artist)}`;
            if (duration > 0) url += `&duration=${duration}`;
        } else if (attempt === 2) {
            url = `https://lrclib.net/api/search?q=${encodeURIComponent(title + " " + artist)}`;
        } else if (attempt === 3) {
            url = `https://lrclib.net/api/search?q=${encodeURIComponent(title)}`;
        } else {
            root.loading = false;
            return;
        }

        Requests.get(url, text => {
            if (reqId !== root.currentRequestId) return;
            if (!text || text.length === 0) {
                fetchAttempt(reqId, title, artist, duration, attempt + 1);
                return;
            }

            try {
                let parsed = JSON.parse(text);
                if (attempt === 0) {
                    if (parsed.syncedLyrics) {
                        updateModel(Lrc.parseLrc(parsed.syncedLyrics));
                        root.loading = false;
                    } else if (parsed.instrumental) {
                        root.loading = false;
                    } else {
                        fetchAttempt(reqId, title, artist, duration, attempt + 1);
                    }
                } else {
                    let results = Array.isArray(parsed) ? parsed : [];
                    let best = pickBestLyricsResult(results, title, artist, duration);
                    if (best && best.syncedLyrics) {
                        updateModel(Lrc.parseLrc(best.syncedLyrics));
                        root.loading = false;
                    } else {
                        fetchAttempt(reqId, title, artist, duration, attempt + 1);
                    }
                }
            } catch(e) {
                fetchAttempt(reqId, title, artist, duration, attempt + 1);
            }
        }, err => {
            if (reqId !== root.currentRequestId) return;
            fetchAttempt(reqId, title, artist, duration, attempt + 1);
        });
    }

    function pickBestLyricsResult(results, title, artist, duration) {
        if (!Array.isArray(results) || results.length === 0)
            return null;

        const titleLower = title.toLowerCase();
        const artistLower = artist.toLowerCase();

        let best = null;
        let bestScore = -Infinity;

        for (const item of results) {
            const syncedLyrics = item?.syncedLyrics ?? "";
            if (!syncedLyrics || syncedLyrics.length === 0)
                continue;

            let score = 0;
            const itemTitle = (item?.trackName ?? item?.name ?? "").toLowerCase();
            const itemArtist = (item?.artistName ?? "").toLowerCase();

            if (itemArtist && itemArtist === artistLower)
                score += 100;
            if (itemTitle && itemTitle === titleLower)
                score += 50;

            if (duration > 0 && typeof item?.duration === "number") {
                const diff = Math.abs(item.duration - duration);
                if (diff <= 2)
                    score += 25;
                else if (diff <= 5)
                    score += 10;
                else
                    score -= Math.min(diff, 30);
            }

            if (item?.instrumental)
                score -= 1000;

            if (syncedLyrics.length < 32)
                score -= 60;

            score += Math.min(syncedLyrics.length, 4000) / 20;

            if (score > bestScore) {
                bestScore = score;
                best = item;
            }
        }

        return best;
    }

    function updateModel(parsedArray) {
        root.currentIndex = -1;
        lyricsModel.clear();
        for (let line of parsedArray) {
            lyricsModel.append({
                time: line.time,
                lyricLine: line.text
            });
        }
    }

    function updatePosition() {
        if (isManualSeeking || loading || !player || lyricsModel.count === 0)
            return;

        let pos = player.position - root.offset;
        let newIdx = -1;
        for (let i = lyricsModel.count - 1; i >= 0; i--) {
            if (pos >= lyricsModel.get(i).time - 0.1) { // 100ms fudge factor
                newIdx = i;
                break;
            }
        }

        if (newIdx !== currentIndex) {
            root.currentIndex = newIdx;
        }
    }

    function jumpTo(index, time) {
        root.isManualSeeking = true;
        root.currentIndex = index;

        if (player) {
            player.position = time + root.offset + 0.01; // compensate for rounding
        }

        seekTimer.restart();
    }

    function initiliazeLyrics() {}

    ListModel {
        id: lyricsModel
    }

    ListModel {
        id: fetchedCandidatesModel
    }

    Timer {
        id: seekTimer

        interval: 500
        onTriggered: root.isManualSeeking = false
    }

    Timer {
        id: loadDebounce

        interval: 50
        onTriggered: root._doLoadLyrics()
    }

    Connections {
        function onActiveChanged() {
            root.player = Players.active;
            loadLyrics();
        }

        target: Players
    }

    Connections {
        function onMetadataChanged() {
            loadLyrics();
        }

        target: root.player
        ignoreUnknownSignals: true
    }

    Component.onCompleted: {
        loadLyrics();
    }
}
