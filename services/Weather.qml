/*--------------------------------------
--- Weather.qml - services by andrel ---
--------------------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	property var location
	property var weather: null

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
		command: ["curl", "-s", `https://api.open-meteo.com/v1/forecast?latitude=${location.lat}&longitude=${location.lon}&daily=weather_code,temperature_2m_max,temperature_2m_min&current=weather_code,temperature_2m,is_day`]
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
