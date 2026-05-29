pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtPositioning

import qs.modules.common

Singleton {
    id: root
    // 10 minute
    readonly property int fetchInterval: Config.options.bar.weather.fetchInterval * 60 * 1000
    readonly property string city: Config.options.bar.weather.city
    readonly property bool useUSCS: Config.options.bar.weather.useUSCS
    property bool gpsActive: Config.options.bar.weather.enableGPS

    property int retryCount: 0
    readonly property int maxRetries: 5

    onUseUSCSChanged: {
        root.getData();
    }
    onCityChanged: {
        root.getData();
    }

    property var location: ({
        valid: false,
        lat: 0,
        lon: 0
    })

    property var data: ({
        uv: 0,
        humidity: 0,
        sunrise: 0,
        sunset: 0,
        moonPhase: "",
        isNight: false,
        currentIcon: "cloud",
        windDir: 0,
        wCode: 0,
        wDesc: "",
        city: 0,
        wind: 0,
        precip: 0,
        visib: 0,
        press: 0,
        temp: 0,
        tempFeelsLike: 0,
        lastRefresh: 0,
    })

    function refineData(data) {
        let temp = {};
        temp.uv = data?.current?.uvIndex || 0;
        temp.humidity = (data?.current?.humidity || 0) + "%";
        temp.sunrise = data?.astronomy?.sunrise || "0.0";
        temp.sunset = data?.astronomy?.sunset || "0.0";
        temp.moonPhase = data?.astronomy?.moon_phase || "";
        
        function parseTimeStr(timeStr) {
            if (!timeStr || timeStr === "0.0") return 0;
            let parts = timeStr.split(" ");
            let hm = parts[0].split(":");
            let h = parseInt(hm[0]);
            let m = parseInt(hm[1]);
            if (parts[1] === "PM" && h !== 12) h += 12;
            if (parts[1] === "AM" && h === 12) h = 0;
            return h * 60 + m;
        }

        let now = new Date();
        let currentMins = now.getHours() * 60 + now.getMinutes();
        let sunriseMins = parseTimeStr(temp.sunrise);
        let sunsetMins = parseTimeStr(temp.sunset);
        temp.isNight = (sunriseMins > 0 && sunsetMins > 0) ? (currentMins < sunriseMins || currentMins > sunsetMins) : false;

        temp.windDir = data?.current?.winddir16Point || "N";
        temp.wCode = data?.current?.weatherCode || "113";
        temp.wDesc = root.getWeatherDescription(temp.wCode);

        let defaultIcon = Icons.getWeatherIcon(temp.wCode);
        if (temp.isNight && defaultIcon === "clear_day") {
            let phase = temp.moonPhase.toLowerCase();
            if (phase.includes("new")) defaultIcon = "brightness_3";
            else if (phase.includes("waxing crescent")) defaultIcon = "brightness_4";
            else if (phase.includes("first quarter")) defaultIcon = "brightness_5";
            else if (phase.includes("waxing gibbous")) defaultIcon = "brightness_6";
            else if (phase.includes("full")) defaultIcon = "brightness_7";
            else if (phase.includes("waning gibbous")) defaultIcon = "brightness_6";
            else if (phase.includes("last quarter")) defaultIcon = "brightness_5";
            else if (phase.includes("waning crescent")) defaultIcon = "brightness_4";
            else defaultIcon = "brightness_2";
        } else if (temp.isNight && defaultIcon === "partly_cloudy_day") {
            defaultIcon = "nights_stay";
        }
        temp.currentIcon = defaultIcon;

        temp.city = data?.location?.areaName[0]?.value || "City";
        temp.temp = "";
        temp.tempFeelsLike = "";
        if (root.useUSCS) {
            temp.wind = (data?.current?.windspeedMiles || 0) + " mph";
            temp.precip = (data?.current?.precipInches || 0) + " in";
            temp.visib = (data?.current?.visibilityMiles || 0) + " m";
            temp.press = (data?.current?.pressureInches || 0) + " psi";
            temp.temp += (data?.current?.temp_F || 0);
            temp.tempFeelsLike += (data?.current?.FeelsLikeF || 0);
            temp.temp += "°F";
            temp.tempFeelsLike += "°F";
        } else {
            temp.wind = (data?.current?.windspeedKmph || 0) + " km/h";
            temp.precip = (data?.current?.precipMM || 0) + " mm";
            temp.visib = (data?.current?.visibility || 0) + " km";
            temp.press = (data?.current?.pressure || 0) + " hPa";
            temp.temp += (data?.current?.temp_C || 0);
            temp.tempFeelsLike += (data?.current?.FeelsLikeC || 0);
            temp.temp += "°C";
            temp.tempFeelsLike += "°C";
        }
        temp.lastRefresh = DateTime.time + " • " + DateTime.date;
        root.data = temp;
    }

    function getData() {
        let command = "curl -s wttr.in";

        if (root.gpsActive && root.location.valid) {
            command += `/${root.location.lat},${root.location.long}`;
        } else {
            command += `/${formatCityName(root.city)}`;
        }

        // format as json
        command += "?format=j1";
        command += " | ";
        // only take the current weather, location, asytronmy data
        command += "jq '{current: .current_condition[0], location: .nearest_area[0], astronomy: .weather[0].astronomy[0]}'";
        fetcher.command[2] = command;
        fetcher.running = false;
        fetcher.running = true;
    }

    function handleFailure() {
        if (root.retryCount < root.maxRetries) {
            root.retryCount++;
            console.warn(`[WeatherService] Fetch failed. Retrying in 5 seconds (Attempt ${root.retryCount}/${root.maxRetries})...`);
            retryTimer.start();
        } else {
            console.error("[WeatherService] Max retries reached. Will try again at the next standard interval.");
            root.retryCount = 0;
        }
    }

    function getWeatherDescription(code) {
        const codeInt = parseInt(code);
        const descriptions = {
            "113": Translation.tr("Clear"),
            "116": Translation.tr("Partly Cloudy"),
            "119": Translation.tr("Cloudy"),
            "122": Translation.tr("Overcast"),
            "143": Translation.tr("Mist"),
            "176": Translation.tr("Patchy Rain"),
            "200": Translation.tr("Thundery Outbreaks"),
            "248": Translation.tr("Fog"),
            "266": Translation.tr("Light Drizzle"),
            "296": Translation.tr("Light Rain"),
            "302": Translation.tr("Moderate Rain"),
            "308": Translation.tr("Heavy Rain"),
            "326": Translation.tr("Light Snow"),
            "332": Translation.tr("Moderate Snow"),
            "338": Translation.tr("Heavy Snow"),
            "353": Translation.tr("Light Rain Shower"),
            "389": Translation.tr("Heavy Rain with Thunder")
        };

        if (descriptions[code]) {
            return descriptions[code];
        }

        let keys = Object.keys(descriptions).map(Number).sort((a, b) => a - b);
        let bestMatch = keys[0];

        for (let i = 0; i < keys.length; i++) {
            if (codeInt >= keys[i]) {
                bestMatch = keys[i];
            } else {
                break;
            }
        }

        return descriptions[bestMatch.toString()] || Translation.tr("Unknown");
    }

    function formatCityName(cityName) {
        return cityName.trim().split(/\s+/).join('+');
    }

    Component.onCompleted: {
        root.getData();
        if (!root.gpsActive) return;
        console.info("[WeatherService] Starting the GPS service.");
        positionSource.start();
    }

    Process {
        id: fetcher
        command: ["bash", "-c", ""]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0) {
                    root.handleFailure();
                    return;
                }
                try {
                    const parsedData = JSON.parse(text);
                    root.refineData(parsedData);
                    root.retryCount = 0;
                } catch (e) {
                    console.error(`[WeatherService] ${e.message}`);
                    root.handleFailure();
                }
            }
        }
    }

    Timer {
        id: retryTimer
        interval: 5000
        repeat: false
        onTriggered: root.getData()
    }

    PositionSource {
        id: positionSource
        updateInterval: root.fetchInterval

        onPositionChanged: {
            // update the location if the given location is valid
            // if it fails getting the location, use the last valid location
            if (position.latitudeValid && position.longitudeValid) {
                root.location.lat = position.coordinate.latitude;
                root.location.long = position.coordinate.longitude;
                root.location.valid = true;
                // console.info(`📍 Location: ${position.coordinate.latitude}, ${position.coordinate.longitude}`);
                root.getData();
                // if can't get initialized with valid location deactivate the GPS
            } else {
                root.gpsActive = root.location.valid ? true : false;
                console.error("[WeatherService] Failed to get the GPS location.");
            }
        }

        onValidityChanged: {
            if (!positionSource.valid) {
                positionSource.stop();
                root.location.valid = false;
                root.gpsActive = false;
                Quickshell.execDetached(["notify-send", Translation.tr("Weather Service"), Translation.tr("Cannot find a GPS service. Using the fallback method instead."), "-a", "Shell"]);
                console.error("[WeatherService] Could not aquire a valid backend plugin.");
            }
        }
    }

    Timer {
        running: !root.gpsActive
        repeat: true
        interval: root.fetchInterval
        triggeredOnStart: !root.gpsActive
        onTriggered: root.getData()
    }
}
