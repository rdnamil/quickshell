/*-------------------------------------
--- Network.qml - widgets by andrel ---
-------------------------------------*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs
import qs.services
import qs.controls
import qs.styles as Style

QsButton { id: root
	// return network icon representing signal strength
	function networkIcon(network) {
		// prevent warnings about type error
		if (!network || typeof network.signal !== "number") return Quickshell.iconPath("network-wireless-offline");

		// return icon to the nearest ¼
		switch (Math.round(network.signal /25) *25) {
			case 0:
				return Quickshell.iconPath("network-wireless-signal-none");
			case 25:
				return Quickshell.iconPath("network-wireless-signal-weak");
			case 50:
				return Quickshell.iconPath("network-wireless-signal-ok");
			case 75:
				return Quickshell.iconPath("network-wireless-signal-good");
			case 100:
				return Quickshell.iconPath("network-wireless-signal-excellent");
		}
	}

	anim: false
	shade: false
	onClicked: {
		if (!popout.isOpen) Network.updateWirelessNetworks();
		popout.toggle();
	}
	content: IconImage {
		implicitSize: GlobalVariables.controls.iconSize
		source: {
			// get the network type -> network state
			switch (Network.status.type) {
				case 'wifi': {
					switch (true) {
						case Network.status.state.includes("connecting"):
							return Quickshell.iconPath("network-wireless-acquiring");
						case Network.status.state === "connected":
							return networkIcon(Network.wirelessNetworks.find(n => n.ssid === Network.status.connection));
						default:
							return Quickshell.iconPath("network-wireless-offline");
					}
				}
						case 'ethernet':
							switch (true) {
								case Network.status.state.includes("connecting"):
									return Quickshell.iconPath("network-wired-acquiring");
								case Network.status.state === "connected":
									return Quickshell.iconPath("network-wired");
								default:
									return Quickshell.iconPath("network-wired-offline");
							}
								default:
									return Quickshell.iconPath("nm-no-connection");
			}
		}
	}

	Popout { id: popout
		onIsOpenChanged: if (!isOpen) bodyContent.ScrollBar.vertical.position = 0.0;
		anchor: root
		header: RowLayout { id: headerContent
			width: screen.width /7

			// wifi adapter toggle
			Row {
				Layout.margins: GlobalVariables.controls.padding
				Layout.rightMargin: 0
				spacing: 3

				IconImage {
					anchors.verticalCenter: parent.verticalCenter
					implicitSize: GlobalVariables.controls.iconSize
					source: Quickshell.iconPath("network-wireless-signal-excellent")
				}

				QsSwitch {
					isOn: Network.status?.radio || false
					onClicked: Network.radio(!isOn);
				}
			}

			// refresh
			QsButton {
				Layout.alignment: Qt.AlignRight
				Layout.margins: GlobalVariables.controls.padding
				Layout.leftMargin: 0
				tooltip: Text {
					text: "Refresh"
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.regular
				}
				onClicked: Network.rescan();
				content: Style.Button {
					IconImage {
						anchors.centerIn: parent
						implicitSize: GlobalVariables.controls.iconSize
						source: Quickshell.iconPath("view-refresh")
					}
				}
			}
		}
		body: ScrollView { id: bodyContent
			topPadding: GlobalVariables.controls.padding
			bottomPadding: GlobalVariables.controls.padding
			width: screen.width /7
			height: Math.min(screen.height /3, layout.height+ topPadding *2)

			ColumnLayout { id: layout
				spacing: GlobalVariables.controls.spacing
				width: bodyContent.width -bodyContent.effectiveScrollBarWidth

				// top padding element
				Item { Layout.preferredHeight: 1; }

				// contected network entry
				QsButton {
					visible: Network.wirelessNetworks.find(n => n.ssid === Network.status.connection) || false
					Layout.fillWidth: true
					Layout.minimumWidth: networkLayout.width
					Layout.preferredHeight: networkLayout.height
					shade: false
					highlight: true
					onClicked: Network.controlNm(["nmcli", "c", "down", "id", Network.status.connection]);
					content: Row { id: networkLayout
						leftPadding: GlobalVariables.controls.padding
						rightPadding: GlobalVariables.controls.padding
						spacing: GlobalVariables.controls.spacing

						// network icon
						IconImage {
							anchors.verticalCenter: parent.verticalCenter
							implicitSize: 24
							source: networkIcon(Network.wirelessNetworks.find(n => n.ssid === Network.status.connection))

							// display if network is encrypted
							IconImage {
								anchors { right: parent.right; bottom: parent.bottom; }
								implicitSize: 8
								source: Quickshell.iconPath("network-wireless-encrypted")
							}
						}

						Column {
							anchors.verticalCenter: parent.verticalCenter

							// network name
							Text {
								text: Network.status.connection || ""
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.regular
							}

							// display on connected network
							Text {
								text: "Connected"
								color: GlobalVariables.colours.windowText
								font: GlobalVariables.font.small
							}
						}
					}
				}

				Repeater {
					model: Network.wirelessNetworks.filter(n => n.ssid && n.ssid !== Network.status.connection) // don't list connected network
					delegate: QsButton {
						required property var modelData

						shade: false
						highlight: true
						Layout.fillWidth: true
						onClicked: Network.controlNm(["nmcli", "d", "w", "c", modelData.ssid]);
						content: Row {
							leftPadding: GlobalVariables.controls.padding
							rightPadding: GlobalVariables.controls.padding
							spacing: GlobalVariables.controls.spacing

							// network icon
							IconImage {
								anchors.verticalCenter: parent.verticalCenter
								implicitSize: 24
								source: networkIcon(modelData)

								// display if network is encrypted
								IconImage {
									anchors { right: parent.right; bottom: parent.bottom; }
									implicitSize: 8
									source: Quickshell.iconPath("network-wireless-encrypted")
								}
							}

							Column {
								anchors.verticalCenter: parent.verticalCenter

								// network name
								Text {
									text: modelData.ssid
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.regular
								}

								Text {
									visible: Network.savedNetworks.some(n => n.ssid.includes(modelData.ssid))
									text: "Saved"
									color: GlobalVariables.colours.windowText
									font: GlobalVariables.font.small
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
