/*--------------------------------
--- NotifyUpdate.qml by andrel ---
--------------------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs
import qs.services
import qs.controls
import qs.styles as Style

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
		onIsOpenChanged: if (!isOpen) bodyContent.ScrollBar.vertical.position = 0.0;
		anchor: root
		header: RowLayout { id: headerContent
			width: screen.width /6

			// update button
			QsButton {
				Layout.margins: GlobalVariables.controls.padding
				Layout.rightMargin: 0
				tooltip: Text {
					text: "Update"
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.regular
				}
				onClicked: Quickshell.execDetached([GlobalVariables.controls.terminal, "-e", "yay"]);
				content: Style.Button {
					IconImage {
						anchors.centerIn: parent
						implicitSize: GlobalVariables.controls.iconSize
						source: Quickshell.iconPath("update")
					}
				}
			}

			// refresh button
			QsButton {
				Layout.alignment: Qt.AlignRight
				Layout.margins: GlobalVariables.controls.padding
				Layout.leftMargin: 0
				tooltip: Text {
					text: "Refresh"
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.regular
				}
				onClicked: NotifyUpdate.refresh();
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
			width: screen.width /6
			height: Math.min(screen.height /3, layout.height+ topPadding *2)

			ColumnLayout { id: layout
				spacing: 0
				width: bodyContent.width -bodyContent.effectiveScrollBarWidth

				// top padding element
				Item { Layout.preferredHeight: 1; }

				Repeater { id: repeater
					model: NotifyUpdate.updates.filter(u => u.package)
					delegate: Rectangle {
						required property var modelData
						required property int index

						Layout.fillWidth: true
						height: update.height
						color: (index % 2 === 0)? "transparent" : GlobalVariables.colours.mid

						Row { id: update
							leftPadding: GlobalVariables.controls.padding
							rightPadding: GlobalVariables.controls.padding
							spacing: GlobalVariables.controls.spacing

							Text {
								anchors.verticalCenter: parent.verticalCenter
								width: 25
								text: `<font color="pink">${repeater.count -index}</font>`
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.mono
							}

							Column {
								topPadding: GlobalVariables.controls.spacing /2
								bottomPadding: GlobalVariables.controls.spacing /2

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

				// bottom padding element
				Item { Layout.preferredHeight: 1; }
			}
		}
	}
}
