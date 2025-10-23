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

QsButton { id: root
	anim: false
	shade: false
	onClicked: popout.toggle();
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
				content: IconImage {
					implicitSize: GlobalVariables.controls.iconSize
					source: Quickshell.iconPath("update")
				}
			}

			QsButton {
				Layout.alignment: Qt.AlignRight
				Layout.margins: GlobalVariables.controls.padding
				Layout.leftMargin: 0
				onClicked: NotifyUpdate.refresh();
				content: IconImage {
					implicitSize: GlobalVariables.controls.iconSize
					source: Quickshell.iconPath("view-refresh")
				}
			}
		}
		body: ScrollView { id: bodyContent
			height: Math.min(updates.height, screen.height /3)
			width: updates.width +effectiveScrollBarWidth
			ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

			ColumnLayout { id: updates
				spacing: 0

				Item { Layout.preferredHeight: 1; }

				Repeater { id: repeater
					model: NotifyUpdate.updates
					delegate: Rectangle {
						required property var modelData
						required property int index

						Layout.fillWidth: true
						Layout.minimumWidth: update.width +GlobalVariables.controls.padding *2
						Layout.minimumHeight: update.height
						color: (index % 2 === 0)? "transparent" : GlobalVariables.colours.mid

						Row { id: update
							x: GlobalVariables.controls.padding
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
									text: `<font color="powderblue">${modelData.repo}/</font><b>${modelData.package}</b>`
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
