/*--------------------------------------
--- Weather.qml - services by andrel ---
--------------------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	property var location: {
		"lat": 0.0,
		"lon": 0.0
	}
	property var weather: null

	function getWeatherIcon(weatherCode, isDay = true) {
		const preffix = "weather-";
		var suffix = "app";

		switch (weatherCode) {
			case 0:
			case 1:
				if (isDay === 1) {
					suffix =  "clear";
				} else {
					suffix =  "clear-night";
				}
				break;
			case 2:
				if (isDay === 1) {
					suffix = "few-clouds";
				} else {
					suffix = "few-clouds-night";
				}
				break;
			case 3:
				suffix = "overcast";
				break;
			case 45:
			case 48:
				suffix = "fog";
				break;
			case 51:
			case 53:
			case 55:
			case 56:
			case 57:
				suffix = "showers-scattered";
				break;
			case 61:
			case 63:
			case 65:
			case 66:
			case 67:
			case 80:
			case 81:
			case 82:
				suffix = "showers";
				break;
			case 71:
			case 73:
			case 75:
			case 77:
			case 85:
			case 86:
				suffix = "snow";
				break;
			case 95:
			case 96:
			case 99:
				suffix = "storm";
				break;
			default:
				suffix = "app";
		}

		return `${preffix}${suffix}`
	}

	Process { id: getLocation
		running: true
		command: ["sh", "-c", 'curl "http://ip-api.com/json?fields=lat,lon"']
		stdout: StdioCollector {
			onStreamFinished: {
				root.location = JSON.parse(text);
				getWeather.running = true;
			}
		}
	}

	Process { id: getWeather
		command: ["curl", "-s", `https://api.open-meteo.com/v1/forecast?latitude=${location.lat}&longitude=${location.lon}&daily=sunrise,sunset,weather_code,temperature_2m_max,temperature_2m_min&current=weather_code,temperature_2m,is_day`]
		stdout: StdioCollector {
			onStreamFinished: root.weather = JSON.parse(text);
		}
	}

	IpcHandler {
		target: "weather"
		function update(): void { getWeather.running = true; }
	}

	Timer {
		interval: 3.6 *10 **6
		running: true
		repeat: true
		onTriggered: getWeather.running = true
	}
}
