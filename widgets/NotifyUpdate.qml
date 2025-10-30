/*----------------------
--- NotifyUpdate.qml ---
----------------------*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import "../"
import "../services"
import "../controls"
import "../styles" as Style

QsButton { id: root
	anim: false
	shade: false
	onClicked: popout.toggle();
	tooltip: Text {
		text: `${NotifyUpdate.updates.filter(u => u.package).length} Updates`
		color: GlobalVariables.colours.text
		font: GlobalVariables.font.regular
	}
	content: IconImage {
		implicitSize: GlobalVariables.controls.iconSize
		source: Quickshell.iconPath("package")

		Rectangle {
			visible: !(NotifyUpdate.updates.length <10)
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
	}

	Popout { id: popout
		anchor: root
		onIsOpenChanged: if (!isOpen) bodyContent.ScrollBar.vertical.position = 0.0;
		header: RowLayout {
			Layout.minimumWidth: 128
			Layout.preferredWidth: bodyContent.width
			width: Math.max(Layout.minimumWidth, Layout.preferredWidth)
			spacing: GlobalVariables.controls.spacing

			QsButton {
				Layout.margins: GlobalVariables.controls.padding
				Layout.rightMargin: 0
				onClicked: {
					Quickshell.execDetached([GlobalVariables.controls.terminal, "-e", "yay"]);
					popout.toggle();
				}
				tooltip: Text {
					text: "Update"
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.regular
				}
				content: Style.Button {
					IconImage {
						anchors.centerIn: parent
						implicitSize: GlobalVariables.controls.iconSize
						source: Quickshell.iconPath("update")
					}
				}
			}

			QsButton {
				Layout.alignment: Qt.AlignRight
				Layout.margins: GlobalVariables.controls.padding
				Layout.leftMargin: 0
				onClicked: NotifyUpdate.refresh();
				tooltip: Text {
					text: "Refresh"
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.regular
				}
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
			height: Math.min(updates.height, screen.height /3)
			width: updates.width +effectiveScrollBarWidth
			ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

			ColumnLayout { id: updates
				Layout.preferredWidth: 128
				spacing: 0

				Item { Layout.preferredHeight: 1; }

				Item {
					visible: !(NotifyUpdate.updates.filter(u => u.package).length >0)
					Layout.preferredWidth: 128
					Layout.preferredHeight: 24
					Layout.margins: 2

					Text {
						anchors.centerIn: parent
						text: "Nothing to do."
						color: GlobalVariables.colours.light
						font: GlobalVariables.font.regular
					}
				}

				Repeater { id: repeater
					model: NotifyUpdate.updates.filter(u => u.package)
					delegate: Rectangle {
						required property var modelData
						required property int index

						Layout.fillWidth: true
						Layout.minimumWidth: update.width +GlobalVariables.controls.padding *2
						Layout.minimumHeight: update.height
						color: (index % 2 === 0)? "transparent" : GlobalVariables.colours.mid

						Row { id: update
							x: GlobalVariables.controls.padding
							topPadding: 1
							bottomPadding: 1
							spacing: GlobalVariables.controls.spacing

							Text {
								anchors.verticalCenter: parent.verticalCenter
								width: 25
								text: `<font color="pink">${repeater.count -index}</font>`
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.mono
							}

							Column {
								Text {
									text: `<b>${modelData.package}</b>`
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.monosmall
								}

								Text {
									text: `<font color="aquamarine">${modelData.oldVersion}</font> <font color="springgreen">--></font> <font color="lightseagreen">${modelData.newVersion}</font>`
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.monosmaller
								}
							}
						}
					}
				}

				Item { Layout.preferredHeight: 1; }
			}
		}
	}
}
