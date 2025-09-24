import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.UPower
import "../"
import "../tools"

SimpleButton { id: root
	darken: false
	animate: false
	onClicked: popout.toggle();
	content: Battery {
		height: 20
		width: 12
		rotation: 90
		// material: true
		percentage: UPower.displayDevice.percentage
		// percentage: 0.5
		isCharging: !UPower.onBattery
	}

	PopoutNew { id: popout
		anchor: root
		header: Row {
			padding: GlobalConfig.padding
			spacing: GlobalConfig.padding

			Row {
				spacing: 3

				Text {
					text: ""
					color: GlobalConfig.colour.foreground
					font.pixelSize: 16
				}

				Switch {
					isOn: PowerProfiles.profile === PowerProfile.PowerSaver
					onClicked: PowerProfiles.profile = isOn? PowerProfile.Balanced : PowerProfile.PowerSaver
				}
			}

			Row {
				spacing: 3

				Text {
					text: "󱐋"
					color: GlobalConfig.colour.foreground
					font.pixelSize: 16
				}

				Switch {
					isOn: PowerProfiles.profile === PowerProfile.Performance
					onClicked: PowerProfiles.profile = isOn? PowerProfile.Balanced : PowerProfile.Performance
				}
			}
		}
		body: Column { id: deviceLayout
			padding: GlobalConfig.padding
			spacing: GlobalConfig.spacing

			Repeater {
				model: UPower.devices

				Row {
					required property var modelData

					visible: modelData.model
					spacing: GlobalConfig.spacing

					Battery {
						anchors.verticalCenter: parent.verticalCenter
						height: 24
						percentage: modelData.percentage
						isCharging: modelData.state === UPowerDeviceState.Charging || modelData.state === UPowerDeviceState.FullyCharged
						material: true
					}

					Column {
						anchors.verticalCenter: parent.verticalCenter

						Text {
							text: modelData.model
							color: GlobalConfig.colour.foreground
							font {
								family: GlobalConfig.font.sans
								pointSize: GlobalConfig.font.regular
							}
						}

						Text {
							text: `${parseInt(modelData.percentage *100)}% ${UPowerDeviceState.toString(modelData.state)}`
							color: GlobalConfig.colour.foreground
							font {
								family: GlobalConfig.font.sans
								pointSize: GlobalConfig.font.small
							}
						}
					}
				}
			}
		}
	}
}
