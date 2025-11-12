/*--------------------------------------
*--- Battery.qml - widgets by andrel ---
*-------------------------------------*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.UPower
import qs
import qs.services
import qs.controls

QsButton { id: root
	readonly property bool isLaptopBattery: UPower.displayDevice?.isLaptopBattery
	readonly property Item tooltipText: Text {
		SystemClock { id: time
			precision: SystemClock.Minutes
		}

		text: {
			var text = `${parseInt(UPower.displayDevice.energy)}W`;

			if (UPower.displayDevice.timeToFull) {
				text = `${formatTimer(UPower.displayDevice.timeToFull)} until fully charged.`;
			}
			if (UPower.displayDevice.timeToEmpty) {
				text = `Until ${formatTime((time.hours *3600 +time.minutes *60) +UPower.displayDevice.timeToEmpty)}`;
			}

			return text;
		}
		color: GlobalVariables.colours.text
		font: GlobalVariables.font.regular
	}

	function formatTime(totalSeconds) {
		var totalMinutes = Math.floor(totalSeconds /60);
		var hours = Math.floor(totalMinutes /60);
		var minutes = totalMinutes -(hours *60);
		return `${hours >0? (hours +":") : ""}${minutes <10 && hours >0? "0" +minutes : minutes}`;
	}

	function formatTimer(totalSeconds) {
		var totalMinutes = Math.floor(totalSeconds /60);
		var hours = Math.floor(totalMinutes /60);
		var minutes = totalMinutes -(hours *60);
		return `${hours >0? (hours +"h") : ""}${minutes}m`;
	}

	anim: false
	shade: false
	tooltip: isLaptopBattery? tooltipText : null
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
			material: true
		}
	}

	Popout { id: popout
		onIsOpenChanged: if (!isOpen) bodyContent.ScrollBar.vertical.position = 0.0;
		anchor: root
		header: RowLayout { id: headerContent
			spacing: GlobalVariables.controls.spacing

			// balanced power profile
			Row {
				Layout.margins: GlobalVariables.controls.padding
				Layout.rightMargin: 0
				spacing: 3

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

			// performance power profile
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
		body: ScrollView { id: bodyContent
			topPadding: GlobalVariables.controls.padding
			bottomPadding: GlobalVariables.controls.padding
			width: screen.width /7
			height: Math.min(screen.height /3, layout.height+ topPadding *2)
			ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

			ColumnLayout { id: layout
				width: bodyContent.width -bodyContent.effectiveScrollBarWidth

				// top padding element
				Item { Layout.preferredHeight: 1; }

				Repeater {
					model: UPower.devices.values.filter(d => d.model)
					delegate: Rectangle {
						required property var modelData
						required property int index

						Layout.fillWidth: true
						Layout.preferredHeight: layout.height
						color: (index %2 === 0)? "transparent" : GlobalVariables.colours.midlight

						RowLayout { id: layout
							width: parent.width
							spacing: GlobalVariables.controls.spacing

							Row {
								Layout.alignment: Qt.AlignVCenter
								Layout.leftMargin: GlobalVariables.controls.padding
								topPadding: GlobalVariables.controls.spacing /2
								bottomPadding: GlobalVariables.controls.spacing /2
								spacing: GlobalVariables.controls.spacing

								IconImage {
									implicitSize: GlobalVariables.controls.iconSize
									source: switch (UPowerDeviceType.toString(modelData.type).toLowerCase()) {
										case "gaming input":
											return Quickshell.iconPath("input-gaming");
										case "battery":
											if (isLaptopBattery) return Quickshell.iconPath("computer-laptop");
											else return Quickshell.iconPath("computer");
										default:
											return Quickshell.iconPath(`input-${UPowerDeviceType.toString(modelData.type).toLowerCase()}`);
									}
								}

								Row {
									spacing: 3

									Text {
										text: modelData.model
										color: GlobalVariables.colours.text
										font: GlobalVariables.font.regular
									}

									Text {
										text: UPowerDeviceState.toString(modelData.state).toLowerCase()
										color: GlobalVariables.colours.windowText
										font: GlobalVariables.font.regular
									}
								}
							}

							Row {
								Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
								Layout.rightMargin: GlobalVariables.controls.padding
								topPadding: GlobalVariables.controls.spacing /2
								bottomPadding: GlobalVariables.controls.spacing /2
								rightPadding: battery.height -battery.width
								spacing: GlobalVariables.controls.spacing

								Text {
									readonly property TextMetrics textMetric: TextMetrics {
										text: "100%"
										font: GlobalVariables.font.regular
									}

									width: textMetric.width
									anchors.verticalCenter: parent.verticalCenter
									text: `${parseInt(modelData.percentage *100)}%`
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.small
								}

								Battery { id: battery
									height: 20
									rotation: 90
									material: true
									percentage: modelData.percentage
									isCharging: modelData.state === UPowerDeviceState.Charging
								}
							}
						}

						Connections {
							target: modelData
							function onPercentageChanged() { if (modelData.percentage === 0.14 && !battery.isCharging) Notifications.notify("battery-level-10", "Quickshell", "Power", `${modelData.model}'s battery is running low.`) }
						}
					}
				}

				// bottom padding element
				Item { Layout.preferredHeight: 1; }
			}
		}
	}
}
