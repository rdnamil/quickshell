/*-------------------------------------
--- Battery.qml - widgets by andrel ---
-------------------------------------*/

import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.UPower
import "../"
import "../services"
import "../controls"

QsButton { id: root
	anim: false
	shade: false
	onClicked: popout.toggle();
	content: Item {
		width: icon.height
		height: icon.width

		Battery { id: icon
			anchors.centerIn: parent
			height: 20
			width: 12
			rotation: 90
			percentage: UPower.displayDevice.percentage
			isCharging: !UPower.onBattery
		}
	}

	Popout { id: popout
		anchor: root
		header: Row {
			padding: GlobalVariables.controls.padding
			spacing: GlobalVariables.controls.spacing

			// set balanced power profile
			Row {
				spacing: 4

				Text {
					text: ""
					color: GlobalVariables.colours.highlightedText
					font.pixelSize: GlobalVariables.controls.iconSize
				}

				QsSwitch {
					isOn: PowerProfiles.profile === PowerProfile.PowerSaver
					onClicked: PowerProfiles.profile = isOn? PowerProfile.Balanced : PowerProfile.PowerSaver;
				}
			}

			// set performance power profile
			Row {
				spacing: 3

				Text {
					text: "󱐋"
					color: GlobalVariables.colours.highlightedText
					font.pixelSize: GlobalVariables.controls.iconSize
				}

				QsSwitch {
					isOn: PowerProfiles.profile === PowerProfile.Performance
					onClicked: PowerProfiles.profile = isOn? PowerProfile.Balanced : PowerProfile.Performance;
				}
			}
		}
		body: Column {
			padding: GlobalVariables.controls.padding
			spacing: GlobalVariables.controls.spacing

			// list devices, their battery, and their status
			Repeater {
				model: UPower.devices
				delegate: Row {
					required property var modelData

					visible: modelData.model
					spacing: GlobalVariables.controls.spacing

					Connections {
						target: modelData
						function onPercentageChanged() { if (modelData.percentage === 0.1 && !battery.isCharging) Notifications.notify("battery-level-10", "Quickshell", "Power", `${modelData.model}'s battery is running low.`) }
					}

					Battery { id: battery
						anchors.verticalCenter: parent.verticalCenter
						height: 24
						material: true
						percentage: modelData.percentage
						isCharging: modelData.state === UPowerDeviceState.Charging
					}

					Column {
						anchors.verticalCenter: parent.verticalCenter

						Text {
							text: modelData.model
							color: GlobalVariables.colours.text
							font: GlobalVariables.font.regular
						}

						Text {
							text: `${parseInt(modelData.percentage *100)}% ${UPowerDeviceState.toString(modelData.state)}`
							color: GlobalVariables.colours.text
							font: GlobalVariables.font.small
						}
					}
				}
			}
		}
	}
}

