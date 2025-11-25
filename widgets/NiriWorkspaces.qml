/*--------------------------------------------
--- NiriWorkspaces.qml - widgets by andrel ---
--------------------------------------------*/

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs
import qs.controls
import qs.services

Row { id: root
	spacing: GlobalVariables.controls.spacing *3 /4
	width: implicitWidth

	Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic; }}

	Repeater {
		model: ScriptModel {
			values: NiriWorkspaces.workspaces
			// filter worskpaces on this.output
			.filter(w => w.output === screen.name)
			// sort in order of idx
			.sort((a ,b) => {
				return a.idx -b.idx;
			})
			objectProp: "id"
		}
		delegate: QsButton { id: workspace
			required property var modelData

			anchors.verticalCenter: parent.verticalCenter
			content: Rectangle {
				width: modelData.is_active? Math.max(windowsLayout.width, 16) : 10
				height: modelData.is_active? Math.max(windowsLayout.height, 10) : 10
				radius: Math.min(width, height) /2
				color: modelData.is_active? GlobalVariables.colours.light : GlobalVariables.colours.mid

				Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.OutCubic; }}
				Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic; }}
			}
			layer.enabled: true
			layer.effect: OpacityMask {
				maskSource: Rectangle {
					width: workspace.content.width
					height: workspace.content.height
					radius: workspace.content.radius
				}
			}

			Rectangle {
				readonly property Item focusedWindow: windowRepeater.itemAt(windowModel.values.findIndex(w => w.is_focused))

				x: focusedWindow.x
				y: focusedWindow.y
				width: focusedWindow.width
				height: width
				radius: height /2
				color: GlobalVariables.colours.highlight

				Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic; }}
			}

			// windows
			Row { id: windowsLayout
				visible: modelData.is_active
				anchors.centerIn: parent
				padding: 2
				spacing: GlobalVariables.controls.spacing *1 /2

				Repeater { id: windowRepeater
					model: ScriptModel { id: windowModel
						values: NiriWorkspaces.windows
						// filter for windows in workspace
						.filter(w => w.workspace_id === modelData.id)
						// filter out floating windows
						.filter(w => w.layout.pos_in_scrolling_layout)
						// sort in order of positiong in scrolling layout
						.sort ((a ,b) => {
							if (a.layout.pos_in_scrolling_layout[0] === b.layout.pos_in_scrolling_layout[0])
								return a.layout.pos_in_scrolling_layout[1] -b.layout.pos_in_scrolling_layout[1];
							else return a.layout.pos_in_scrolling_layout[0] -b.layout.pos_in_scrolling_layout[0];
						})
						objectProp: "id"
					}
					delegate: QsButton {
						required property var modelData

						width: content.width +4
						height: width
						content: Rectangle{
							readonly property list<color> colours: [
								"#f4dbd6",
								"#f0c6c6",
								"#ee99a0",
								"#ed8796",
								"#f5a97f",
								"#eed49f",
								"#a6da95",
								"#8bd5ca",
								"#91d7e3",
								"#7dc4e4",
								"#8aadf4",
								"#b7bdf8",
								"#c6a0f6"
							]

							anchors.centerIn: parent
							width: 8
							height: width
							radius: height /2
							color: colours[Math.floor(Math.random() * colours.length)];
							border { width: 1; color: Qt.darker(GlobalVariables.colours.highlight, 1.6); }
						}
					}
				}
			}
		}
	}
}
