/*-------------------------------------
--- Weather.qml - widgets by andrel ---
-------------------------------------*/

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs
import qs.services

Loader { id: root
	// property var location
	// property var weather: null

	active: Weather.weather
	sourceComponent: Row {
		readonly property string condition: switch (Weather.weather.current_weather.weathercode) {
			case 0:
			case 1:
				if (Weather.weather.current_weather.is_day === 1) {
					return "-clear";
				} else {
					return "-clear-night";
				}
				break;
			case 2:
				if (Weather.weather.current_weather.is_day === 1) {
					return "-few-clouds";
				} else {
					return "-few-clouds-night";
				}
				break;
			case 3:
				return "-overcast";
				break;
			case 45:
			case 48:
				return "-fog";
				break;
			case 51:
			case 53:
			case 55:
			case 56:
			case 57:
				return "-showers-scattered";
				break;
			case 61:
			case 63:
			case 65:
			case 66:
			case 67:
			case 80:
			case 81:
			case 82:
				return "-showers";
				break;
			case 71:
			case 73:
			case 75:
			case 77:
			case 85:
			case 86:
				return "-snow";
				break;
			case 95:
			case 96:
			case 99:
				return "-storm";
				break;
			default:
				return "-app";
		}

		spacing: 2

		IconImage { id: weatherIcon
			anchors.verticalCenter: parent.verticalCenter
			implicitSize: GlobalVariables.controls.iconSize
			source: Quickshell.iconPath(`weather${condition}`)
		}

		Row {
			Text { id: temperature
				text: parseInt(Weather.weather.current_weather.temperature)
				color: GlobalVariables.colours.text
				font: GlobalVariables.font.semibold
			}

			Text {
				text: Weather.weather.current_weather_units.temperature
				color: GlobalVariables.colours.text
				topPadding: 3
				font: GlobalVariables.font.smaller
			}
		}
	}
}
