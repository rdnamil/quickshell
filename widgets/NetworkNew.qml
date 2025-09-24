/*------------------------------
--- Network widget by andrel ---
------------------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "root:"
import "root:/tools"
import "network"

SimpleButton { id: root
	darken: false
	animate: false
	onClicked: popout.toggle()
	content: Item {
		width: GlobalConfig.iconSize
		height: width

		NetworkIcon { network: NetworkManager.activeNetwork; showLock: false; }
	}

	PopoutNew { id: popout
		anchor: root
		header: Row {
			padding: GlobalConfig.padding
			spacing: GlobalConfig.spacing

			Row {
				spacing: 3
				IconImage {
					anchors.verticalCenter: parent.verticalCenter
					implicitSize: GlobalConfig.iconSize
					source: Quickshell.iconPath("network-wireless-signal-excellent")
				}
				Switch {}
			}

			Row {
				spacing: 3
				IconImage {
					anchors.verticalCenter: parent.verticalCenter
					implicitSize: GlobalConfig.iconSize
					source: Quickshell.iconPath("airplane-mode")
				}
				Switch {}
			}
		}
		body: ScrollView { id: networkList
			anchors.centerIn: parent
			height: Math.min(networkListLayout.height, 250)

			ColumnLayout { id: networkListLayout
				spacing: GlobalConfig.spacing

				Item {
					Layout.fillWidth: true
					height: 1
				}

				Repeater {
					model: NetworkManager.networks

					SimpleButton {
						required property var modelData

						Layout.fillWidth: true
						visible: modelData.ssid
						onClicked: {
							if (!modelData.inUse) {
								networkControl.command = ["nmcli", "dev", "wifi", "connect", modelData.ssid];
								networkControl.running = true;
							} else {
								networkControl.command = ["nmcli", "con", "down", "id", modelData.ssid];
								networkControl.running = true;
							}
						}
						content: Row { id: networkLayout
							leftPadding: GlobalConfig.padding
							rightPadding: GlobalConfig.padding
							spacing: GlobalConfig.spacing

							NetworkIcon {
								anchors.verticalCenter: parent.verticalCenter
								implicitSize: 24
								network: modelData
							}

							Column {
								anchors.verticalCenter: parent.verticalCenter

								Text {
									text: modelData.ssid
									color: GlobalConfig.colour.foreground
									font {
										family: GlobalConfig.font.sans
										pointSize: GlobalConfig.font.regular
										weight: { if (modelData.inUse) return GlobalConfig.font.semibold; }
									}
								}

								Text {
									visible: modelData.inUse
									text: "Connected"
									color: GlobalConfig.colour.foreground
									font {
										family: GlobalConfig.font.sans
										pointSize: GlobalConfig.font.small
									}
								}
							}
						}

						Process { id: networkControl
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
