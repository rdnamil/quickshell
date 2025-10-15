/*------------------------
--- Tray.qml by andrel ---
------------------------*/

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import ".."
import "../controls"

Row { id: root
	spacing: GlobalVariables.controls.spacing /2	// spacing for tray items

	Repeater {
		model: SystemTray.items

		// tray item
		QsButton {
			required property var modelData

			anim: false
			shade: false
			onClicked: popout.toggle();
			content: IconImage {
				implicitSize: GlobalVariables.controls.iconSize
				source: modelData.icon
			}

			QsMenuOpener { id: menu
				menu: modelData.menu
			}

			QsMenuAnchor { id: menuAnchor
				anchor.item: root
				menu: modelData.menu
			}

			// tray item menu
			Popout { id: popout
				// debug: true
				anchor: parent
				body: ColumnLayout {
					spacing: GlobalVariables.controls.spacing /2

					// top padding element
					Item { Layout.preferredHeight: GlobalVariables.controls.padding /2 }

					Repeater { id: menuEntries
						// get values from the tray item menu to pass to all entries
						readonly property bool hasIcon: menu.children.values.some(child => child.icon)
						readonly property bool hasButton: menu.children.values.some(child => child.buttonType)
						readonly property bool hasChildren: menu.children.values.some(child => child.hasChildren)

						model: menu.children.values.filter(child => !child.hasChildren)	// temporarily hide entries with children until submenus made

						// menu entry
						QsButton { id: menuEntry
							required property var modelData
							required property int index

							visible: !(modelData.isSeparator && index === 0) // don't show separators above all entries
							Layout.fillWidth: true
							anim: !modelData.isSeparator
							shade: false
							highlight: !modelData.isSeparator
							onPressed: {
								if (modelData.buttonType) {
									modelData.triggered();
									menuAnchor.open();
									menuAnchor.close();
								}
							}
							onClicked: {
								if (!modelData.isSeparator && !modelData.buttonType) {
									modelData.triggered();
									popout.close();
								}
							}
							content: Item {
								width: entryLayout.width
								height: modelData.isSeparator? 6 : entryLayout.height

								// separator entry
								Rectangle {
									visible: modelData.isSeparator
									anchors {
										left: parent.left
										leftMargin: menuEntry.width /2 -width /2
										verticalCenter: parent.verticalCenter
									}
									width: menuEntry.width *0.75
									height: 1
									color: GlobalVariables.colours.text
									opacity: 0.2

									Rectangle {
										anchors { horizontalCenter: parent.horizontalCenter; top: parent.bottom; }
										width: parent.width
										height: 1
										color: GlobalVariables.colours.midlight
									}
								}

								// regular entry
								Row { id: entryLayout
									visible: !modelData.isSeparator
									leftPadding: GlobalVariables.controls.padding
									rightPadding: GlobalVariables.controls.padding
									spacing: GlobalVariables.controls.spacing

									// button; can be checkbox or radio-button
									Item {
										anchors.verticalCenter: parent.verticalCenter
										visible: menuEntries.hasButton
										width: GlobalVariables.controls.iconSize
										height: width

										// checkbox button
										Rectangle {
											visible: modelData.buttonType === QsMenuButtonType.CheckBox
											anchors.fill: parent
											radius: 3
											color: modelData.checkState !== Qt.Unchecked? GlobalVariables.colours.accent : GlobalVariables.colours.midlight

											Rectangle {
												visible: modelData.checkState !== Qt.Unchecked
												x: 2
												y: 9
												width: 6
												height: 2
												rotation: 45
												color: GlobalVariables.colours.text

												Rectangle {
													anchors { right: parent.right; bottom: parent.top; }
													height: 9
													width: 2
													color: parent.color
												}
											}
										}

										// radio-button button
										Rectangle {
											visible: modelData.buttonType === QsMenuButtonType.RadioButton
											anchors.fill: parent
											radius: height /2
											color: modelData.checkState !== Qt.Unchecked? GlobalVariables.colours.accent : GlobalVariables.colours.midlight

											Rectangle {
												visible: modelData.checkState !== Qt.Unchecked
												anchors.centerIn: parent
												width: parent.width *0.5
												height: width
												radius: height /2
												color: GlobalVariables.colours.text
											}
										}
									}

									// icon
									IconImage {
										anchors.verticalCenter: parent.verticalCenter
										visible: menuEntries.hasIcon
										implicitSize: GlobalVariables.controls.iconSize
										source: modelData.icon
									}

									// entry text
									Text {
										text: modelData.text
										color: GlobalVariables.colours.text
										font: GlobalVariables.font.regular
									}
								}
							}
						}
					}

					// padding bellow menu entries
					Item { height: GlobalVariables.controls.padding /2 }
				}
			}
		}
	}
}
