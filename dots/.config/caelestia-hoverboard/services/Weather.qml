pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia
import Caelestia.Config
import qs.utils

Singleton {
    id: root

    property bool configLoaded: false
    property string lastFetchedLocation: ""

    FileView {
        id: barConfigFile
        path: (Quickshell.env("HOME") || "/home/zatch") + "/.config/illogical-impulse/config.json"
        preload: true
        watchChanges: true
        onLoaded: {
            root.configLoaded = true;
            Qt.callLater(root.reload);
        }
    }

    FileView {
        id: weatherCacheFile
        path: (Quickshell.env("HOME") || "/home/zatch") + "/.cache/caelestia-hoverboard/weather-cache.json"
        preload: true
        onLoaded: {
            try {
                const cacheText = weatherCacheFile.text();
                if (cacheText) {
                    const cache = JSON.parse(cacheText);
                    if (cache.city) city = cache.city;
                    if (cache.loc) loc = cache.loc;
                    if (cache.lastFetchedLocation) lastFetchedLocation = cache.lastFetchedLocation;
                    if (cache.cc) cc = cache.cc;
                    if (cache.forecast) forecast = cache.forecast;
                    if (cache.hourlyForecast) hourlyForecast = cache.hourlyForecast;
                }
            } catch (e) {
                console.error(`[WeatherCache] Error parsing cache: ${e.message}`);
            }
        }
    }

    readonly property var barConfigData: {
        try {
            return JSON.parse(barConfigFile.text() || "{}");
        } catch(e) {
            return {};
        }
    }

    readonly property string configuredBarCity: Quickshell.env("SKWD_WEATHER_CITY") || (barConfigData?.bar?.weather?.city ?? "")

    readonly property string targetCity: configuredBarCity || GlobalConfig.services.weatherLocation

    onConfiguredBarCityChanged: {
        root.reload();
    }

    property string city
    property string loc
    property var cc
    property list<var> forecast
    property list<var> hourlyForecast

    readonly property string icon: cc ? Icons.getWeatherIcon(cc.weatherCode) : "cloud_alert"
    readonly property string description: cc?.weatherDesc ?? qsTr("No weather")
    readonly property string temp: GlobalConfig.services.useFahrenheit ? `${cc?.tempF ?? 0}°F` : `${cc?.tempC ?? 0}°C`
    readonly property string feelsLike: GlobalConfig.services.useFahrenheit ? `${cc?.feelsLikeF ?? 0}°F` : `${cc?.feelsLikeC ?? 0}°C`
    readonly property int humidity: cc?.humidity ?? 0
    readonly property real windSpeed: cc?.windSpeed ?? 0
    readonly property string sunrise: cc ? formatAstroTime(cc.sunrise) : "--:--"
    readonly property string sunset: cc ? formatAstroTime(cc.sunset) : "--:--"

    readonly property var cachedCities: new Map()

    function reload(): void {
        const configLocation = targetCity;

        if (configLocation) {
            if (configLocation === lastFetchedLocation)
                return;
            lastFetchedLocation = configLocation;

            if (configLocation.indexOf(",") !== -1 && !isNaN(parseFloat(configLocation.split(",")[0]))) {
                loc = configLocation;
                fetchCityFromCoords(configLocation);
            } else {
                fetchCoordsFromCity(configLocation);
            }
        } else if (!loc || timer.elapsed() > 900) {
            if (!configLoaded)
                return;
            lastFetchedLocation = "";
            Requests.get("https://ipinfo.io/json", text => {
                const response = JSON.parse(text);
                if (response.loc) {
                    loc = response.loc;
                    city = response.city ?? "";
                    timer.restart();
                }
            });
        }
    }

    function fetchCityFromCoords(coords: string): void {
        if (cachedCities.has(coords)) {
            city = cachedCities.get(coords);
            return;
        }

        const [lat, lon] = coords.split(",").map(s => s.trim());

        const fallbackToBigDataCloud = () => {
            const fallbackUrl = `https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${lat}&longitude=${lon}&localityLanguage=en`;
            Requests.get(fallbackUrl, text => {
                const geo = JSON.parse(text);
                const geoCity = geo.city || geo.locality;
                if (geoCity) {
                    city = geoCity;
                    cachedCities.set(coords, geoCity);
                } else {
                    city = "Unknown City";
                }
            });
        };

        const nominatimUrl = `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lon}&format=geocodejson`;
        Requests.get(nominatimUrl, text => {
            const geo = JSON.parse(text).features?.[0]?.properties.geocoding;
            if (geo) {
                const geoCity = geo.type === "city" ? geo.name : geo.city;
                if (geoCity) {
                    city = geoCity;
                    cachedCities.set(coords, geoCity);
                    return;
                }
            }
            fallbackToBigDataCloud();
        }, fallbackToBigDataCloud);
    }

    function fetchCoordsFromCity(cityName: string): void {
        const url = `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(cityName)}&count=1&language=en&format=json`;

        Requests.get(url, text => {
            const json = JSON.parse(text);
            if (json.results && json.results.length > 0) {
                const result = json.results[0];
                loc = result.latitude + "," + result.longitude;
                city = result.name;
            } else {
                loc = "";
                reload();
            }
        });
    }

    function fetchWeatherData(): void {
        const url = getWeatherUrl();
        if (url === "")
            return;

        Requests.get(url, text => {
            const json = JSON.parse(text);
            if (!json.current_condition || !json.weather)
                return;
            
            const current = json.current_condition[0];
            const astro = json.weather[0].astronomy[0];

            cc = {
                weatherCode: current.weatherCode,
                weatherDesc: getWeatherCondition(current.weatherCode),
                tempC: Math.round(parseFloat(current.temp_C)),
                tempF: Math.round(parseFloat(current.temp_F)),
                feelsLikeC: Math.round(parseFloat(current.FeelsLikeC)),
                feelsLikeF: Math.round(parseFloat(current.FeelsLikeF)),
                humidity: parseInt(current.humidity),
                windSpeed: parseFloat(current.windspeedKmph),
                isDay: 1, // wttr.in doesn't explicitly have this on root, we'll just assume day or parse icon
                sunrise: astro.sunrise,
                sunset: astro.sunset
            };

            const forecastList = [];
            for (let i = 0; i < json.weather.length; i++) {
                const day = json.weather[i];
                forecastList.push({
                    date: day.date.replace(/-/g, "/"),
                    maxTempC: Math.round(parseFloat(day.maxtempC)),
                    maxTempF: Math.round(parseFloat(day.maxtempF)),
                    minTempC: Math.round(parseFloat(day.mintempC)),
                    minTempF: Math.round(parseFloat(day.mintempF)),
                    weatherCode: day.hourly[0].weatherCode, // Just use the first hour's code
                    icon: Icons.getWeatherIcon(day.hourly[0].weatherCode)
                });
            }
            forecast = forecastList;
            
            // wttr.in only has 3 hourly entries per day usually (or 8 for 3 hour blocks). We will just clear hourlyForecast since it's barely used.
            hourlyForecast = [];

            // Save the loaded data to cache.
            root.saveCache();
        });
    }

    function saveCache(): void {
        const cache = {
            city: city,
            loc: loc,
            lastFetchedLocation: lastFetchedLocation,
            cc: cc,
            forecast: forecast,
            hourlyForecast: hourlyForecast
        };
        const cacheData = JSON.stringify(cache);
        Quickshell.execDetached([
            "python3",
            "-c",
            "import sys, os; p = os.path.expanduser('~/.cache/caelestia-hoverboard'); os.makedirs(p, exist_ok=True); open(os.path.join(p, 'weather-cache.json'), 'w').write(sys.argv[1])",
            cacheData
        ]);
    }

    function toFahrenheit(celcius: real): real {
        return celcius * 9 / 5 + 32;
    }

    function getWeatherUrl(): string {
        if (!loc || loc.indexOf(",") === -1)
            return "";

        const [lat, lon] = loc.split(",").map(s => s.trim());
        return `https://wttr.in/${lat},${lon}?format=j1`;
    }

    function formatAstroTime(timeStr: string): string {
        if (!timeStr) return "--:--";
        const match = timeStr.match(/^(\d{2}):(\d{2})\s*(AM|PM)$/i);
        if (!match) return timeStr;
        
        let hours = parseInt(match[1], 10);
        const minutes = match[2];
        const ampm = match[3].toUpperCase();
        
        if (GlobalConfig.services.useTwelveHourClock) {
            return `${hours}:${minutes} ${ampm}`;
        } else {
            if (ampm === "PM" && hours < 12) {
                hours += 12;
            } else if (ampm === "AM" && hours === 12) {
                hours = 0;
            }
            const hoursStr = hours.toString().padStart(2, "0");
            return `${hoursStr}:${minutes}`;
        }
    }

    function getWeatherCondition(code: string): string {
        const codeInt = parseInt(code);
        const descriptions = {
            "113": "Clear",
            "116": "Partly Cloudy",
            "119": "Cloudy",
            "122": "Overcast",
            "143": "Mist",
            "176": "Patchy Rain",
            "200": "Thundery Outbreaks",
            "248": "Fog",
            "266": "Light Drizzle",
            "296": "Light Rain",
            "302": "Moderate Rain",
            "308": "Heavy Rain",
            "326": "Light Snow",
            "332": "Moderate Snow",
            "338": "Heavy Snow",
            "353": "Light Rain Shower",
            "389": "Heavy Rain with Thunder"
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

        return descriptions[bestMatch.toString()] || "Unknown";
    }

    onLocChanged: fetchWeatherData()

    Connections {
        function onWeatherLocationChanged(): void {
            root.reload();
        }

        target: GlobalConfig.services
    }

    Timer {
        interval: 3600000 // 1 hour
        running: true
        repeat: true
        onTriggered: fetchWeatherData()
    }

    ElapsedTimer {
        id: timer
    }
}
