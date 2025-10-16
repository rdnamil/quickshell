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
	readonly property bool isLaptopBattery: UPower.displayDevice.isLaptopBattery

	anim: false
	shade: false
	onClicked: popout.toggle();
	content: Item {
		width: isLaptopBattery? icon.height : icon.width
		height: isLaptopBattery? icon.width : icon.height

		Battery { id: icon
			anchors.centerIn: parent
			height: isLaptopBattery? 20 : 16
			width: isLaptopBattery? 12 : 10
			rotation: isLaptopBattery? 90 : 0
			percentage: isLaptopBattery? UPower.displayDevice.percentage : 1.0
			isCharging: isLaptopBattery? !UPower.onBattery : false
			material: !isLaptopBattery
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
						function onPercentageChanged() { if (modelData.percentage === 0.14 && !battery.isCharging) Notifications.notify("battery-level-10", "Quickshell", "Power", `${modelData.model}'s battery is running low.`) }
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

