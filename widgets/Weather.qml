/*---------------------------
--- Weather.qml by andrel ---
---------------------------*/

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../"

Loader { id: root
	property var weather: null

	active: weather
	sourceComponent: Row {
		readonly property string condition: {
			switch (weather.current_weather.weathercode) {
				case 0 || 1:
					if (weather.current_weather.is_day === 1) {
						return "-clear";
					} else {
						return "-clear-night";
					}
				case 2:
					if (weather.current_weather.is_day === 1) {
						return "-few-clouds";
					} else {
						return "-few-clouds-night";
					}
				case 3:
					return "-overcast";
				case 45 || 48:
					return "-fog";
				case 51 || 53 || 55 || 56 || 57:
					return "-showers-scattered";
				case 61 || 63 || 65 || 66 || 67 || 80 || 81 || 82:
					return "-showers";
				case 71 || 73 || 75 || 77 || 85 || 86:
					return "-snow";
				case 95 || 96 || 99:
					return "-storm";
				default:
					return "-app";
			}
		}

		spacing: 2

		IconImage {
			anchors.verticalCenter: parent.verticalCenter
			implicitSize: GlobalVariables.controls.iconSize
			source: Quickshell.iconPath(`weather${condition}`)
		}

		Row {
			Text { id: temperature
				text: parseInt(weather.current_weather.temperature)
				color: GlobalVariables.colours.text
				font: GlobalVariables.font.semibold
			}

			Text {
				text: weather.current_weather_units.temperature
				color: GlobalVariables.colours.text
				topPadding: 3
				font: GlobalVariables.font.smaller
			}
		}
	}

	Process { id: weatherApi
		running: true
		command: ["curl", "-s", `https://api.open-meteo.com/v1/forecast?latitude=${GlobalVariables.weather.longitude}&longitude=${GlobalVariables.weather.latitude}&current_weather=true`]
		stdout: StdioCollector {
			onStreamFinished: { weather = JSON.parse(text); }
		}
	}

	IpcHandler {
		target: "weather"
		function update(): void { weatherApi.running = true; }
	}

	Timer {
		interval: 3.6 *10 **6
		running: true
		repeat: true
		onTriggered: weatherApi.running = true
	}
}
