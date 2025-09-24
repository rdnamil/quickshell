/*--------------------------------
--- Bluetooth widget by andrel ---
--------------------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Bluetooth
import "../"
import "../tools"

SimpleButton { id: root
	readonly property BluetoothAdapter bluetoothAdapter: Bluetooth.defaultAdapter
	readonly property bool isEnabled: bluetoothAdapter.state === BluetoothAdapterState.Enabled
	readonly property bool isConnected: bluetoothAdapter.devices.values.some(device => device.connected)

	darken: false
	animate: false
	onClicked: popout.toggle();
	content: IconImage {
		implicitSize: GlobalConfig.iconSize
		source: isEnabled? Quickshell.iconPath("bluetooth") : Quickshell.iconPath("bluetooth-disabled")

		// draw dots when connected to a device
		Item {
			visible: isConnected
			anchors.fill: parent

			Rectangle {
				anchors { left: parent.left; verticalCenter: parent.verticalCenter; }
				width: 2
				height: width
				radius: height /2
			}

			Rectangle {
				anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
				width: 2
				height: width
				radius: height /2
			}
		}
	}

	PopoutNew { id: popout
		anchor: root
		header: RowLayout {
			width: bodyContent.width

			Process { id: toggleDevice
				running: false
				command: isEnabled? ["bluetoothctl", "power", "off"] : ["bluetoothctl", "power", "on"]
			}

			Row {
				Layout.margins: GlobalConfig.padding
				Layout.rightMargin: 0
				spacing: 3

				IconImage {
					anchors.verticalCenter: parent.verticalCenter
					implicitSize: GlobalConfig.iconSize
					source: Quickshell.iconPath("bluetooth")
				}

				Switch {
					isOn: isEnabled
					onClicked: toggleDevice.running = true;
				}
			}

			// spacer
			Item { Layout.fillWidth: true; Layout.fillHeight: true; }

			SimpleButton {
				Layout.margins: GlobalConfig.padding
				Layout.leftMargin: 0
				animate: false
				onClicked: { if (bluetoothAdapter.discovering) {
					bluetoothAdapter.discovering = false;
					scanTimer.stop();
				} else {
					bluetoothAdapter.discovering = true;
					scanTimer.restart();
				}
				}
				content: IconImage { id: scanIcon
					implicitSize: GlobalConfig.iconSize
					source: Quickshell.iconPath("add")
					rotation: bluetoothAdapter.discovering? 45 : 0

					Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.InCirc; }}
				}

				Timer { id: scanTimer
					running: false
					interval: 10000
					onTriggered: bluetoothAdapter.discovering = false;
				}
			}
		}
		body: ScrollView { id: bodyContent
			anchors.centerIn: parent
			height: Math.min(deviceListLayout.height, 250)

			ColumnLayout { id: deviceListLayout
				spacing: GlobalConfig.spacing

				Item { Layout.fillWidth: true; height: 1; }

				Repeater {
					model: Bluetooth.defaultAdapter.devices

					SimpleButton { id: device
						required property var modelData

						function pair() {
							deviceControl.command = ["bluetoothctl", "pair", modelData.address];
							deviceControl.running = true;
						}

						function trust() {
							deviceControl.command = ["bluetoothctl", "trust", modelData.address];
							deviceControl.running = true;
						}

						function connect() {
							deviceControl.command = ["bluetoothctl", "connect", modelData.address];
							deviceControl.running = true;
						}

						function disconnect() {
							deviceControl.command = ["bluetoothctl", "disconnect", modelData.address];
							deviceControl.running = true;
						}

						Layout.fillWidth: true
						drawBackground: true
						onClicked: {
							if (!modelData.paired) device.pair();
							if (!modelData.connected && modelData.paired) {
								device.connect();
							} else {
								device.disconnect();
							}
						}
						content: Row {
							leftPadding: GlobalConfig.padding
							rightPadding: GlobalConfig.padding
							spacing: GlobalConfig.spacing

							IconImage {
								anchors.verticalCenter: parent.verticalCenter
								implicitSize: 24
								source: Quickshell.iconPath(modelData.icon, "blueman-device")
							}

							Column {
								anchors.verticalCenter: parent.verticalCenter

								Text {
									text: modelData.name
									color: GlobalConfig.colour.foreground
									font {
										family: GlobalConfig.font.sans
										pointSize: GlobalConfig.font.regular
										weight: if (modelData.connected) return GlobalConfig.font.semibold;
									}
								}

								Text {
									visible: modelData.connected
									text: "Connected"
									color: GlobalConfig.colour.foreground
									font {
										family: GlobalConfig.font.sans
										pointSize: GlobalConfig.font.small
										weight: GlobalConfig.font.thin
									}
								}

								Text {
									visible: modelData.pairing
									text: "Pairing..."
									color: GlobalConfig.colour.foreground
									font {
										family: GlobalConfig.font.sans
										pointSize: GlobalConfig.font.small
										weight: GlobalConfig.font.thin
									}
								}
							}
						}

						Connections {
							target: modelData
							function onPairedChanged() {
								if (modelData.paired) { device.connect(); device.trust(); }
							}
						}

						Process { id: deviceControl
							running: false
						}
					}
				}

				Item {
					Layout.fillWidth: true
					height: 1
				}
			}
		}
	}
}
