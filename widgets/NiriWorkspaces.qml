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

			// highlight focused window
			Rectangle { id: highlight
				readonly property Item focusedWindow: windowRepeater.itemAt(windowModel.values.findIndex(w => w.is_focused))

				x: focusedWindow?.x
				y: focusedWindow?.y +focusedWindow?.height /2 -height /2
				width: focusedWindow?.width
				height: focusedWindow?.height
				radius: height /2
				color: GlobalVariables.colours.midlight

				Behavior on x { ParallelAnimation {
					NumberAnimation { duration: 250; }

					SequentialAnimation {
						NumberAnimation {
							target: highlight
							property: "width"
							// from: width
							to: highlight.focusedWindow?.width *3 /2 || null
							duration: 125
							easing.type: Easing.OutCubic;
						}

						NumberAnimation {
							target: highlight
							property: "width"
							// from: width *1 /3
							to: highlight.focusedWindow?.width || null
							duration: 125
							easing.type: Easing.OutCubic;
						}
					}

					SequentialAnimation {
						NumberAnimation {
							target: highlight
							property: "height"
							// from: width
							to: highlight.focusedWindow?.height *3 /4 || null
							duration: 125
							easing.type: Easing.InCubic;
						}

						NumberAnimation {
							target: highlight
							property: "height"
							// from: width *1 /3
							to: highlight.focusedWindow?.height || null
							duration: 125
							easing.type: Easing.InCubic;
						}
					}
				}}
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

						width: content.width +6
						height: width
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
							width: 6
							height: width
							radius: height /2
							// color: GlobalVariables.colours.accent
							color: colours[Math.floor(Math.random() * colours.length)];
							// border { width: 1; color: Qt.darker(GlobalVariables.colours.highlight, 1.6); }
						}
					}
				}
			}
		}
	}
}
