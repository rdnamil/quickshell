/*--------------------
--- QsDropdown.qml ---
--------------------*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import "../"
import "../styles"

QsButton { id: root
	required property list<string> options

	property string selection: options[0]

	function close() {
		dropdown.visible = false;
	}

	signal selected(string option)

	anim: false
	onClicked: dropdown.visible = !dropdown.visible;
	content: Rectangle {
		width: root.width
		height: 24
		topLeftRadius: GlobalVariables.controls.radius
		topRightRadius: GlobalVariables.controls.radius
		bottomLeftRadius: dropdown.visible? 0 : GlobalVariables.controls.radius
		bottomRightRadius: dropdown.visible? 0 : GlobalVariables.controls.radius
		color: GlobalVariables.colours.base

		RowLayout {
			anchors.verticalCenter: parent.verticalCenter
			width: parent.width

			Text {
				Layout.alignment: Qt.AlignVCenter
				Layout.leftMargin: GlobalVariables.controls.padding
				Layout.fillWidth: true
				text: selection
				elide: Text.ElideRight
				color: GlobalVariables.colours.text
				font: GlobalVariables.font.regular
			}

			IconImage {
				Layout.alignment: Qt.AlignVCenter
				Layout.rightMargin: GlobalVariables.controls.padding
				implicitSize: GlobalVariables.controls.iconSize
				source: dropdown.visible? Quickshell.iconPath("arrow-up") : Quickshell.iconPath("arrow-down")
			}
		}

		Borders {}
	}

	PopupWindow { id: dropdown
		visible: false
		anchor {
			item: root;
			rect.y: root.height -1; // prefer window bellow bar
		}
		color: "transparent"
		implicitWidth: scrollView.width
		implicitHeight: scrollView.height

		Rectangle {
			anchors.fill: parent
			bottomLeftRadius: GlobalVariables.controls.radius
			bottomRightRadius: GlobalVariables.controls.radius
			color: GlobalVariables.colours.alternateBase
			layer.enabled: true
			layer.effect: OpacityMask {
				maskSource: Rectangle {
					width: dropdown.width
					height: dropdown.height
					bottomLeftRadius: GlobalVariables.controls.radius
					bottomRightRadius: GlobalVariables.controls.radius
				}
			}

			ScrollView { id: scrollView
				width: root.width
				height: Math.min(screen.height /3, list.height +GlobalVariables.controls.spacing *2)
				topPadding: GlobalVariables.controls.spacing
				bottomPadding: GlobalVariables.controls.spacing

				ColumnLayout { id: list
					spacing: 6
					width: root.width

					Repeater {
						model: options
						delegate: QsButton { id: option
							required property var modelData

							Layout.fillWidth: true
							Layout.preferredHeight: content.height
							shade: false
							highlight: true
							onClicked: {
								root.selected(modelData);
								dropdown.visible = !dropdown.visible;
							}
							content: Text {
								anchors {
									left: parent.left
									leftMargin: GlobalVariables.controls.padding
								}
								width: root.width -GlobalVariables.controls.padding *2
								text: modelData
								elide: Text.ElideRight
								color: GlobalVariables.colours.text
								font: modelData === selection? GlobalVariables.font.semibold : GlobalVariables.font.regular
							}
						}
					}
				}
			}

			Borders {}
		}
	}
}
