import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import ".."
import "../tools"

Row { id: root
	spacing: 2	// spacing for tray items

	Repeater {
		model: SystemTray.items

		// tray item
		SimpleButton {
			required property var modelData

			darken: false
			animate: false
			onClicked: popout.toggle();
			content: IconImage {
				implicitSize: GlobalConfig.iconSize
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
			PopoutNew { id: popout
				// debug: true
				anchor: parent
				body: ColumnLayout {
					spacing: 0

					// padding above menu entries
					Item {
						Layout.fillWidth: true
						Layout.preferredHeight: GlobalConfig.padding /2
					}

					Repeater { id: menuEntries
						// get values from the tray item menu to pass to all entries
						readonly property bool hasIcon: menu.children.values.some(child => child.icon)
						readonly property bool hasButton: menu.children.values.some(child => child.buttonType)
						readonly property bool hasChildren: menu.children.values.some(child => child.hasChildren)

						// model: menu.children
						model: menu.children.values.filter(child => !child.hasChildren)	// temporarily hide entries with children until submenus made

						// menu entry
						SimpleButton { id: menuEntry
							required property var modelData
							required property int index

							visible: !(modelData.isSeparator && index === 0) // don't show separators above all entries
							Layout.fillWidth: true
							darken: false
							animate: !modelData.isSeparator
							drawBackground: !modelData.isSeparator
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
								}
							}
							onAnimCompleted: if (!modelData.isSeparator) popout.close();
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
									color: GlobalConfig.colour.foreground
									opacity: 0.25

									Rectangle {
										anchors { horizontalCenter: parent.horizontalCenter; top: parent.bottom; }
										width: parent.width
										height: 1
										color: GlobalConfig.colour.midground
									}
								}

								// regular entry
								Row { id: entryLayout
									visible: !modelData.isSeparator
									leftPadding: GlobalConfig.padding
									rightPadding: GlobalConfig.padding
									spacing: GlobalConfig.spacing

									// button; can be checkbox or radio-button
									Item {
										anchors.verticalCenter: parent.verticalCenter
										visible: menuEntries.hasButton
										width: GlobalConfig.iconSize
										height: width

										// checkbox button
										Rectangle {
											visible: modelData.buttonType === QsMenuButtonType.CheckBox
											anchors.fill: parent
											radius: 3
											color: modelData.checkState !== Qt.Unchecked? GlobalConfig.colour.accent :  GlobalConfig.colour.grey

											Rectangle {
												visible: modelData.checkState !== Qt.Unchecked
												x: 2
												y: 9
												width: 6
												height: 2
												rotation: 45
												color: GlobalConfig.colour.foreground

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
											color: modelData.checkState !== Qt.Unchecked? GlobalConfig.colour.accent :  GlobalConfig.colour.grey

											Rectangle {
												visible: modelData.checkState !== Qt.Unchecked
												anchors.centerIn: parent
												width: parent.width *0.5
												height: width
												radius: height /2
												color: GlobalConfig.colour.foreground
											}
										}
									}

									// icon
									IconImage {
										anchors.verticalCenter: parent.verticalCenter
										visible: menuEntries.hasIcon
										implicitSize: GlobalConfig.iconSize
										source: modelData.icon
									}

									// entry text
									Text {
										text: modelData.text
										color: GlobalConfig.colour.foreground
										font {
											family: GlobalConfig.font.sans
											pointSize: GlobalConfig.font.regular
										}
									}
								}
							}
						}
					}

					// padding bellow menu entries
					Item {
						Layout.fillWidth: true
						height: GlobalConfig.padding /2
					}
				}
			}
		}
	}
}
