/*--------------------------------------
--- NiriWorkspaces_Alt.qml by andrel ---
--------------------------------------*/

import QtQuick
import Quickshell
import qs
import qs.controls as Ctrl
import qs.services as Service
import qs.styles as Style

Row { id: root
	property var workspaceSize: QtObject {
		property size active: "14x10"
		property size inactive: "10x10"
	}
	property size windowSize: "12x12"
	property list<color> colours: [
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

	function getRandomColour() {
		var c = colours[Math.floor(Math.random() *colours.length)];
		return c;
	}

	spacing: 6
	width: implicitWidth

	Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutCirc; }}

	Repeater {
		model: ScriptModel { id: workspaceModel
			values: Service.NiriWorkspaces.workspaces
			// filter worskpaces on this.output
			.filter(w => w.output === screen.name)
			// sort in order of idx
			.sort((a ,b) => {
				return a.idx -b.idx;
			})
			objectProp: "id"
		}
		delegate: Item {
			required property var modelData

			readonly property bool hasWindows: !(!modelData.is_active || windowModel.values < 1)

			width: hasWindows? windows.width : modelData.is_active? root.workspaceSize.active.width : root.workspaceSize.inactive.width
			height: Math.max(root.workspaceSize.active.height, root.workspaceSize.inactive.height, root.windowSize.height)

			// workspaces
			Rectangle { id: workspace
				visible: !hasWindows
				anchors.centerIn: parent
				width: hasWindows? root.workspaceSize.inactive.width : modelData.is_active? root.workspaceSize.active.width : root.workspaceSize.inactive.width
				height: hasWindows? root.workspaceSize.inactive.height : modelData.is_active? root.workspaceSize.active.height : root.workspaceSize.inactive.height
				radius: Math.min(width, height) /2
				color: modelData.is_active? GlobalVariables.colours.text : GlobalVariables.colours.midlight

				Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCirc; }}
				// Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCirc; }}
			}

			// windows
			Row { id: windows
				readonly property var parentModel: parent.modelData

				anchors.centerIn: parent
				spacing: 4
				move: Transition { id: move
					NumberAnimation { property: "x"; duration: 250; easing.type: Easing.OutCirc; }
				}


				Repeater { id: windowRepeater
					model: ScriptModel { id: windowModel
						values: Service.NiriWorkspaces.windows
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
					delegate: Rectangle {
						required property int index

						readonly property bool isActive: parent.parentModel.is_active
						readonly property real xOffset: windowTrans.x

						width: root.windowSize.width
						height: root.windowSize.height
						radius: Math.min(width, height) /2
						color: root.getRandomColour()
						opacity: parent.parentModel.is_active? 1.0 : 0.0
						transform: Translate { id: windowTrans
							x: parent.parentModel.is_active? 0 : parent.width /2 -width /2 -(width +parent.spacing) *index

							Behavior on x { NumberAnimation { duration: isActive? 250 : 0; easing.type: Easing.OutCirc; }}
						}

						Behavior on opacity { NumberAnimation { duration: isActive? 250 : 0; easing.type: Easing.OutCirc; }}
					}
				}
			}

			// highlight
			Rectangle { id: highlight
				readonly property var focusedWindow: windowRepeater.itemAt(windowModel.values?.findIndex(w => w.id === modelData.active_window_id)) || null

				visible: (modelData.is_active && focusedWindow)
				anchors.verticalCenter: parent.verticalCenter
				x: focusedWindow?.x +focusedWindow?.width /2 -width /2 || width /2
				width: {
					var size = Math.floor(focusedWindow?.width /2);

					if (focusedWindow?.width %2 !== size %2) size += 1;

					return Math.max(size, 1);
				}
				height: {
					var size = Math.floor(focusedWindow?.height /2);

					if (focusedWindow?.height %2 !== size %2) size += 1;

					return Math.max(size, 1);
				}
				radius: Math.min(width, height) /2
				color: GlobalVariables.colours.dark
				// color: "red"
				transform: Translate { x: highlight.focusedWindow?.xOffset || 0; }

				Behavior on x { NumberAnimation { duration: move.running? 0 : 250; easing.type: Easing.OutCirc; }}
			}
		}
	}
}

// Rectangle { id: workspace
// 	required property int index
//
// 	width: 8
// 	height: width
// 	radius: height /2
// 	color: "blue"
// 	transform: Translate {
// 		x: root.collapse? 0 : parent.width /2 -width /2 -(width +root.spacing) *index
//
// 		Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCirc; }}
// 	}
// }
