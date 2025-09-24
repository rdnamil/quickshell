/*--------------------------------
--- Bluetooth widget by andrel ---
--------------------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Widgets
import "root:"
import "root:/tools"
import "bluetooth"

Item { id: root
	readonly property bool isEnabled: (Bluetooth.defaultAdapter.state === BluetoothAdapterState.Enabled)

	property bool connected: false

	width: icon.width
	height: icon.height

	SimpleButton { id: icon
		darken: false
		animate: false
		onClicked: { menu.toggle(); layout.selectedDevice = null; }
		content: IconImage {
			implicitSize: GlobalConfig.iconSize
			source: {
				switch (Bluetooth.defaultAdapter.state) {
					case BluetoothAdapterState.Enabled:
						return Quickshell.iconPath("bluetooth");
						break;
					default:
						return Quickshell.iconPath("bluetooth-disabled");
						break;
				}
			}
		}
	}

	Popout { id: menu
		anchor: root
		content: Item {
			width: layout.width +GlobalConfig.padding *2
			height: layout.height +GlobalConfig.padding *2

			Process { id: changeState
				running: false
				command: toggle.isOn? ["bluetoothctl", "power", "off"] : ["bluetoothctl", "power", "on"]
			}

			RectangularShadow {
				anchors.fill: headerBack
				radius: headerBack.radius
				spread: 0
				blur: 30
				// color: "red"
			}

			Rectangle { id: headerBack
				width: parent.width
				height: header.height +GlobalConfig.padding *2
				radius: GlobalConfig.cornerRadius
				color: GlobalConfig.colour.surface
			}

			ColumnLayout { id: layout
				property var selectedDevice: null

				anchors.centerIn: parent

				RowLayout { id: header
					Layout.bottomMargin: 12
					Layout.minimumWidth: 150

					Row {
						spacing: 2

						IconImage {
							anchors.verticalCenter: parent.verticalCenter
							implicitSize: GlobalConfig.iconSize
							source: Quickshell.iconPath("bluetooth")
						}
						Switch { id: toggle
							isOn: isEnabled
							onClicked: changeState.running = true;
						}
					}

					Item { Layout.fillWidth: true; }

					SimpleButton { id: scan
						onClicked: { Bluetooth.defaultAdapter.discovering = !Bluetooth.defaultAdapter.discovering; }
						content: IconImage { id: scanIcon
							implicitSize: GlobalConfig.iconSize
							source: Quickshell.iconPath("view-refresh")
							rotation: 0
						}

						NumberAnimation { id: spinAnim
							running: Bluetooth.defaultAdapter.discovering
							target: scanIcon
							property: "rotation"
							from: 0
							to: 360
							duration: 1000
							loops: 5
							onStopped: { scanIcon.rotation = 0; Bluetooth.defaultAdapter.discovering = false; }
						}
					}
				}

				Repeater {
					model: Bluetooth.defaultAdapter.devices

					SimpleButton { id: entry
						required property var modelData

						animate: false
						onClicked: layout.selectedDevice = modelData;
						content: RowLayout { id: entryLayout
							spacing: 6
							opacity: entryOptions.visible? 0.2 : 1.0

							Behavior on opacity { NumberAnimation{ duration: 200; }}

							Item {
								width: icon.width +infoLayout.width
								height: 32

								IconImage { id: icon
									anchors.verticalCenter: parent.verticalCenter
									implicitSize: parent.height
									source: Quickshell.iconPath(modelData.icon, "blueman-device")
								}

								Column { id: infoLayout
									anchors { right: parent.right; bottom: parent.bottom; }
									rightPadding: 3
									spacing: 6

									Rectangle {
										visible: modelData.connected
										anchors { left: parent.left; leftMargin: batteryLayout.visible? 2: 0; }
										width: 5
										height: width
										radius: height /2
										color: GlobalConfig.colour.green
									}

									Row { id: batteryLayout
										visible: modelData.batteryAvailable
										spacing: 1

										Battery { id: battery
											width: 10
											height: 16
											percentage: modelData.battery
										}

										Text {
											anchors { bottom: parent.bottom; bottomMargin: -3; }
											text: parseInt(battery.percentage *100) +"%"
											color: GlobalConfig.colour.foreground
											font {
												family: GlobalConfig.font.mono
												pointSize: GlobalConfig.font.small
											}
										}
									}
								}

							}

							Column {
								Text {
									text: modelData.name
									color: GlobalConfig.colour.foreground
									font.family: GlobalConfig.font.sans
									font.pointSize: 10
									font.weight: 600
								}

								Text {
									text: modelData.address
									color: GlobalConfig.colour.midground
									font.family: GlobalConfig.font.sans
									font.pointSize: 8
									// font.weight: 400
								}
							}
						}

						Item { id: entryOptions
							visible: (layout.selectedDevice === modelData)
							width: layout.width
							height: parent.height

							RowLayout {
								anchors.fill: parent
								spacing: 0

								SimpleButton {
									visible: toggle.isOn
									Layout.fillWidth: true
									onClicked: {
										if (!modelData.connected) {
											 modelData.connect();
										} else {
											modelData.disconnect();
										}
										// if (!modelData.paired) modelData.pair();
										// optionSelected.restart();
									}
									content: IconImage {
										implicitSize: GlobalConfig.iconSize
										source: !modelData.connected? Quickshell.iconPath("link") : Quickshell.iconPath("remove-link")
									}
								}
								SimpleButton {
									visible: modelData.paired
									Layout.fillWidth: true
									onClicked: {
										modelData.trusted = !modelData.trusted
										// optionSelected.restart();
									}
									content: IconImage {
										implicitSize: GlobalConfig.iconSize
										source: !modelData.trusted? Quickshell.iconPath("blueman-trust") : Quickshell.iconPath("blueman-untrust")
									}
								}
								SimpleButton {
									visible: modelData.paired
									Layout.fillWidth: true
									onClicked: {
										modelData.forget();
										// optionSelected.restart();
									}
									content: IconImage {
										implicitSize: GlobalConfig.iconSize
										source: modelData.paired? Quickshell.iconPath("radio-mixed") : Quickshell.iconPath("radio-checked")
									}
								}
								SimpleButton {
									Layout.fillWidth: true
									onClicked: { optionSelected.restart(); }
									content: IconImage {
										implicitSize: GlobalConfig.iconSize
										source: Quickshell.iconPath("close")
									}
								}
							}

							SequentialAnimation { id: optionSelected
								NumberAnimation { duration: 150; }
								ScriptAction { script: layout.selectedDevice = null; }
							}
						}
					}
				}
			}
		}
	}
}
