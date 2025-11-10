/*-------------------------------------
--- Weather.qml - widgets by andrel ---
-------------------------------------*/

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs
import qs.controls
import qs.services as Service

Loader { id: root
	function getWeatherIcon(weatherCode, isDay = true) {
		switch (weatherCode) {
			case 0:
			case 1:
				if (isDay === 1) {
					return "-clear";
				} else {
					return "-clear-night";
				}
				break;
			case 2:
				if (isDay === 1) {
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
	}

	active: Service.Weather.weather
	sourceComponent: QsButton { id: icon
		shade: false
		anim: false
		onClicked: popout.toggle();
		content: Row {
			spacing: 3

			IconImage { id: weatherIcon
				anchors.verticalCenter: parent.verticalCenter
				implicitSize: GlobalVariables.controls.iconSize
				source: Quickshell.iconPath(`weather${getWeatherIcon(Service.Weather.weather.current.weather_code, Service.Weather.weather.current.is_day)}`)
			}

			Row {
				Text { id: temperature
					text: parseInt(Service.Weather.weather.current.temperature_2m)
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.semibold
				}

				Text {
					text: Service.Weather.weather.current_units.temperature_2m
					color: GlobalVariables.colours.text
					topPadding: 3
					font: GlobalVariables.font.smaller
				}
			}
		}

		Popout { id: popout
			anchor: icon
			// header: ColumnLayout {}
			body: Item {
				width: screen.width /7
				height: bodyLayout.height

				Rectangle {
					anchors {
						left: parent.left
						leftMargin: GlobalVariables.controls.padding
						verticalCenter: parent.verticalCenter
					}
					width: (parent.width -(GlobalVariables.controls.padding *2) -(bodyLayout.spacing *6)) /7
					height: parent.height -GlobalVariables.controls.spacing *2
					radius: GlobalVariables.controls.radius
					color: GlobalVariables.colours.accent
					opacity: 0.4
				}

				RowLayout { id: bodyLayout
					anchors.horizontalCenter: parent.horizontalCenter
					width: parent.width -GlobalVariables.controls.padding *2
					uniformCellSizes: true

					Repeater {
						model: 7
						delegate: ColumnLayout {
							required property int index

							readonly property date today: new Date()

							spacing: GlobalVariables.controls.spacing
							Layout.fillWidth: true
							Layout.topMargin: GlobalVariables.controls.padding
							Layout.bottomMargin: GlobalVariables.controls.padding

							Text {
								Layout.fillWidth: true
								text: Qt.formatDate(new Date(today.getFullYear(), today.getMonth(), today.getDate() +index), "ddd")
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.bold
								horizontalAlignment: Text.AlignHCenter
							}

							IconImage {
								Layout.fillWidth: true
								Layout.alignment: Qt.AlignHCenter
								implicitSize: GlobalVariables.controls.iconSize
								source: Quickshell.iconPath(`weather${getWeatherIcon(Service.Weather.weather.daily.weather_code[index], true)}`)
							}

							Text {
								Layout.fillWidth: true
								text: `${parseInt(Service.Weather.weather.daily.temperature_2m_min[index])}${Service.Weather.weather.daily_units.temperature_2m_min}\n${parseInt(Service.Weather.weather.daily.temperature_2m_max[index])}${Service.Weather.weather.daily_units.temperature_2m_max}`
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.small
								horizontalAlignment: Text.AlignHCenter
							}
						}
					}
				}
			}
		}
	}
}
