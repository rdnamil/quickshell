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

	Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}

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
			onClicked: Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", modelData.idx]);
			content: Rectangle {
				width: modelData.is_active? Math.max(windowsLayout.width, 16) : 10
				height: modelData.is_active? Math.max(windowsLayout.height, 10) : 10
				radius: Math.min(width, height) /2 -1
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

			// highlight focused window
			Rectangle { id: highlight
				readonly property Item focusedWindow: windowRepeater.itemAt(windowModel.values.findIndex(w => w.is_focused))

				visible: modelData.is_active
				x: focusedWindow?.x +focusedWindow?.width /2 -width /2
				y: focusedWindow?.y +focusedWindow?.height /2 -height /2
				width: focusedWindow?.height +4
				height: focusedWindow?.height +4
				radius: height /2
				// color: GlobalVariables.colours.dark
				color: focusedWindow.randomColour
				transform: Scale { id: highlightTrans
					// origin.x: highlight.width /2
					origin.y: highlight.height /2
				}

				Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.OutCubic; }}
				Behavior on x { ParallelAnimation {
					NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }

					// SequentialAnimation {
					// 	NumberAnimation {
					// 		target: highlightTrans
					// 		property: "xScale"
					// 		// from: width
					// 		to: 3 /2
					// 		duration: 125
					// 		easing.type: Easing.OutCubic;
					// 	}
     //
					// 	NumberAnimation {
					// 		target: highlightTrans
					// 		property: "xScale"
					// 		// from: width *1 /3
					// 		to: 1.0
					// 		duration: 125
					// 		easing.type: Easing.OutCubic;
					// 	}
					// }

					SequentialAnimation {
						NumberAnimation {
							target: highlightTrans
							property: "yScale"
							// from: width
							to: 3 /4
							duration: 125
							easing.type: Easing.OutCubic;
						}

						NumberAnimation {
							target: highlightTrans
							property: "yScale"
							// from: width *1 /3
							to: 1.0
							duration: 125
							easing.type: Easing.OutCubic;
						}
					}
				}}
			}

			// windows
			Row { id: windowsLayout
				visible: modelData.is_active
				anchors.centerIn: parent
				padding: 4
				spacing: GlobalVariables.controls.spacing *3 /4

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
					delegate: QsButton { id: window
						required property var modelData

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
						readonly property color randomColour: colours[Math.floor(Math.random() * colours.length)];

						// width: content.width +6
						// height: width
						tooltip: Text {
							text: modelData.title
							color: GlobalVariables.colours.text
							font: GlobalVariables.font.regular
						}
						onClicked: {
							Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", modelData.id]);
							Quickshell.execDetached(["niri", "msg", "action", "center-window"]);
						}
						content: Rectangle{
							anchors.centerIn: parent
							width: modelData.is_focused? 6 : 6
							height: width
							radius: height /2
							color: GlobalVariables.colours.mid
							// color: modelData.is_focused? window.randomColour : GlobalVariables.colours.mid

							Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.OutCubic; }}
						}
					}
				}
			}
		}
	}
}
