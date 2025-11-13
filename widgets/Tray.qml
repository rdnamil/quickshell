/*------------------------
--- Tray.qml by andrel ---
------------------------*/

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs
import qs.controls
import qs.styles as Style

Row { id: root
	spacing: GlobalVariables.controls.spacing /1.5

	// system tray items
	Repeater {
		model: SystemTray.items.values
		delegate: Item { id: systemTrayItem
			required property var modelData

			width: GlobalVariables.controls.iconSize
			height: width

			IconImage {
				implicitSize: GlobalVariables.controls.iconSize
				source: Quickshell.iconPath(modelData.id.toLowerCase(), true) || modelData.icon
			}

			Rectangle {
				visible: modelData.status === Status.NeedsAttention
				anchors {
					horizontalCenter: parent.right
					top: parent.top
					topMargin: -height /3
				}
				width: 10
				height: width
				radius: height /2
				color: "#bb2040"
				border.color: GlobalVariables.colours.base
			}

			MouseArea {
				anchors.centerIn: parent
				width: parent.width +4
				height: width
				hoverEnabled: true
				// show/hide tooltip
				onEntered: if (modelData.title) tooltipTimer.restart();
				onExited: if (modelData.title) {
					tooltipTimer.stop();
					tooltip.isShown = false;
				}
				onClicked: (mouse) => {
					switch (mouse.button) {
						// toggle menu
						case Qt.LeftButton:
							if (modelData.hasMenu) popout.toggle();
							break;
						// trigger system tray item action
						case Qt.RightButton:
							modelData.activate();
							break;
						// trigger system tray item secondary action
						case Qt.MiddleButton:
							modelData.secondaryActivate();
							break;
					}
				}
				// trigger system tray scroll action
				onWheel: (wheel) => {
					modelData.scroll(wheel.angleDelta.y /120, false);
				}

				// tooltip
				QsTooltip { id: tooltip
					anchor: parent
					content: Text {
						text: modelData.title
						color: GlobalVariables.colours.text
						font: GlobalVariables.font.regular
					}

					Timer { id: tooltipTimer
						running: false
						interval: 1500
						onTriggered: parent.isShown = true;
					}
				}
			}

			// system platform menu *must be refreshed to update menu entries
			QsMenuAnchor { id: menuAnchor
				function toggle() {
					if (menuAnchor.visible) menuAnchor.close();
					else menuAnchor.open();
				}

				function refresh() {
					menuAnchor.open();
					menuAnchor.close();
				}

				anchor.item: systemTrayItem
				menu: modelData.menu
			}

			// access to menuhandle
			QsMenuOpener { id: menuOpener
				readonly property bool hasIcon: children.values.some(e => e.icon)
				readonly property bool hasButton: children.values.some(e => e.buttonType !== QsMenuButtonType.None)

				menu: modelData.menu
			}

			// system tray item menu
			Popout { id: popout
				anchor: systemTrayItem
				body: ColumnLayout { id: bodyLayout
					// top padding element
					Item { Layout.preferredHeight: 1; }

					// menu entries
					Repeater {
						model: menuOpener.children.values.filter(e => !e.hasChildren).filter((e, i, arr) => {
							const prev = arr[i - 1];
							const next = arr[i + 1];

							if ((i === 0 || i === arr.length - 1) && e.isSeparator) return false;
							if (e.isSeparator && (prev?.isSeparator || next == null)) return false;

							return true;
						});
						delegate: QsButton { id: menuEntry
							required property var modelData
							required property int index

							// if can interact with meny entry
							readonly property bool interactive: modelData.enabled && !modelData.isSeparator
							// seperator item
							readonly property Item separatorEntry: Style.Margin { anchors.fill: parent; opacity: 0.4; }
							// regular menu entry item
							readonly property Item textMenuEntry: RowLayout {
								anchors.fill: parent
								spacing: GlobalVariables.controls.spacing

								// left padding element
								Item { Layout.preferredWidth: 1; }

								// button
								Item {
									visible: menuOpener.hasButton
									width: GlobalVariables.controls.iconSize
									height: width

									QsStateButton {
										visible: type
										type: modelData.buttonType
										checkState: modelData.checkState
									}
								}

								// icon
								Item {
									visible: menuOpener.hasIcon
									width: GlobalVariables.controls.iconSize
									height: width

									IconImage {
										visible: source
										implicitSize: GlobalVariables.controls.iconSize
										source: modelData.icon
									}
								}

								// text
								Text {
									Layout.fillWidth: true
									text: modelData.text
									color: modelData.hasChildren? "red" : GlobalVariables.colours.text
									font: GlobalVariables.font.regular
								}

								// right padding element
								Item { Layout.preferredWidth: 1; }
							}

							Layout.fillWidth: true
							Layout.minimumWidth: content.implicitWidth
							shade: false
							anim: interactive
							highlight: interactive
							// update button
							onPressed: if (interactive && modelData.buttonType !== QsMenuButtonType.None) {
								modelData.triggered();
								menuAnchor.refresh();
							}
							// trigger menu entry action
							onClicked: if (interactive && modelData.buttonType === QsMenuButtonType.None) {
								modelData.triggered();
								menuAnchor.refresh();
								popout.close();
							}
							content: modelData.isSeparator? separatorEntry : textMenuEntry
						}
					}

					// bottom padding element
					Item { Layout.preferredHeight: 1; }
				}
			}
		}
	}
}
