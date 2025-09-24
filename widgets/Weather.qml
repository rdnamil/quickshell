/*------------------------------
--- Weather widget by andrel ---
------------------------------*/

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import ".."

Row { id: root
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

	property var weather

	spacing: 2

	IconImage {
		anchors.verticalCenter: parent.verticalCenter
		implicitSize: GlobalConfig.iconSize
		source: Quickshell.iconPath(`weather${condition}`)
	}

	Row {
		Text { id: temperature
			text: parseInt(weather.current_weather.temperature) || "nan"
			color: GlobalConfig.colour.foreground
			font {
				family: GlobalConfig.font.sans
				pointSize: GlobalConfig.font.regular
				weight: GlobalConfig.font.semibold
			}
		}

		Text {
			text: weather.current_weather_units.temperature
			color: GlobalConfig.colour.foreground
			topPadding: 3
			font {
				family: GlobalConfig.font.sans
				pointSize: GlobalConfig.font.smaller
				// weight: GlobalConfig.font.semibold
			}
			onTextChanged: Component.reload();
		}
	}

	Process { id: weatherApi
		running: true
		command: ["curl", "-s", `https://api.open-meteo.com/v1/forecast?latitude=${GlobalConfig.weather.longitude}&longitude=${GlobalConfig.weather.latitude}&current_weather=true`]
		stdout: StdioCollector {
			onStreamFinished: weather = JSON.parse(text);
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
