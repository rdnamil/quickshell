/*------------------------------
*--- Bluetooth.qml - widgets ---
*-----------------------------*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Widgets
import "../"
import "../services"
import "../controls"
import "../styles" as Style

QsButton { id: root
	anim: false
	shade: false
	onClicked: popout.toggle();
	onMiddleClicked: Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
	content: IconImage {
		implicitSize: GlobalVariables.controls.iconSize
		source: {
			switch (Bluetooth.defaultAdapter.state) {
				case BluetoothAdapterState.Enabled:
					return Quickshell.iconPath("bluetooth-active");
				case BluetoothAdapterState.Disabled:
					return Quickshell.iconPath("bluetooth-disabled");
			}
		}
	}

	Popout { id: popout
		onIsOpenChanged: if (!isOpen) bodyContent.ScrollBar.vertical.position = 0.0;
		anchor: root
		header: RowLayout { id: headerContent
			width: screen.width /6

			// bluetooth adapter toggle
			Row {
				Layout.margins: GlobalVariables.controls.padding
				Layout.rightMargin: 0
				spacing: 3

				IconImage {
					anchors.verticalCenter: parent.verticalCenter
					implicitSize: GlobalVariables.controls.iconSize
					source: Quickshell.iconPath("bluetooth")
				}

				QsSwitch {
					isOn: Bluetooth.defaultAdapter.enabled
					onClicked: Bluetooth.defaultAdapter.enabled = !isOn;
				}
			}

			// scan/add devices
			QsButton {
				Layout.alignment: Qt.AlignRight
				Layout.margins: GlobalVariables.controls.padding
				Layout.leftMargin: 0
				tooltip: Text {
					text: "Scan"
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.regular
				}
				onClicked: Bluetooth.defaultAdapter.discovering = !Bluetooth.defaultAdapter.discovering;
				content: Style.Button {
					IconImage {
						anchors.centerIn: parent
						implicitSize: GlobalVariables.controls.iconSize
						source: Quickshell.iconPath("add")
						rotation: discoveringInterval.running? 45 : 0

						Behavior on rotation { NumberAnimation { duration: 100; easing.type: Easing.InCirc; }}
					}
				}

				Timer { id: discoveringInterval
					running: Bluetooth.defaultAdapter.discovering
					interval: 5000
					onTriggered: Bluetooth.defaultAdapter.discovering = false;
				}
			}
		}
		body: ScrollView { id: bodyContent
			topPadding: GlobalVariables.controls.padding
			bottomPadding: GlobalVariables.controls.padding
			width: screen.width /6
			height: Math.min(screen.height /3, layout.height+ topPadding *2)

			ColumnLayout { id: layout
				spacing: GlobalVariables.controls.spacing
				width: bodyContent.width -bodyContent.effectiveScrollBarWidth

				// top padding element
				Item { Layout.preferredHeight: 1; }

				Repeater {
					model: Bluetooth.defaultAdapter.devices
					delegate: QsButton {
						required property var modelData

						shade: false
						highlight: true
						Layout.fillWidth: true
						onClicked: {
							if (!modelData.paired) {
								Quickshell.execDetached(["bluetoothctl", "pair", modelData.address]);
							} else if (!modelData.connected) {
								Quickshell.execDetached(["bluetoothctl", "connect", modelData.address]);
							} else {
								Quickshell.execDetached(["bluetoothctl", "disconnect", modelData.address]);
							}
						}
						content: Row { id: bodyLayout
							leftPadding: GlobalVariables.controls.padding
							rightPadding: GlobalVariables.controls.padding
							spacing: GlobalVariables.controls.spacing

							IconImage {
								anchors.verticalCenter: parent.verticalCenter
								implicitSize: 24
								source: Quickshell.iconPath(modelData.icon, "blueman-device")
							}

							Column {
								anchors.verticalCenter: parent.verticalCenter

								Text {
									text: modelData.name
									color: (modelData.state === (BluetoothDeviceState.Connecting ||  BluetoothDeviceState.Disconnecting)) || modelData.pairing? GlobalVariables.colours.windowText : GlobalVariables.colours.text
									font: GlobalVariables.font.regular
								}

								Text {
									visible: modelData.connected
									text: modelData.connected? "Connected" : null
									color: GlobalVariables.colours.windowText
									font: GlobalVariables.font.small
								}

								Text {
									visible: !modelData.connected
									text: modelData.address
									color: GlobalVariables.colours.windowText
									font: GlobalVariables.font.monosmaller
								}
							}
						}

						Connections {
							target: modelData

							// connect to and trust device once paired
							function onPairedChanged() {
								if (modelData.paired) {
									Quickshell.execDetached(["bluetoothctl", "connect", modelData.address]);
									Quickshell.execDetached(["bluetoothctl", "trust", modelData.address]);
								}
							}

							// send notification on device status changed
							function onConnectedChanged() {
								if (modelData.connected) {
									Notifications.notify("bluetooth", "Quickshell", "Bluetooth", `Connected to ${modelData.name}.`);
								} else {
									Notifications.notify("bluetooth", "Quickshell", "Bluetooth", `Disconnected from ${modelData.name}.`);
								}
							}
						}
					}
				}

				// bottom padding element
				Item { Layout.preferredHeight: 1; }
			}
		}
	}
}
