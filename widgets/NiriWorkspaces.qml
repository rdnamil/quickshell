/*--------------------------------------------
--- NiriWorkspaces.qml - widgets by andrel ---
--------------------------------------------*/

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import qs
import qs.services
import qs.controls

Loader { id: root
	// get list on workspaces on this.screen
	readonly property list<var> workspaces: NiriWorkspaces.workspaces.filter(w => w.output === screen.name)
	// get the current active workspace for this.screen
	readonly property var activeWorkspace: NiriWorkspaces.activeWorkspace.filter(w => w.output == screen.name).find(w => w.is_active)
	// get windows in the current active workspace
	readonly property var windows: Array.from(NiriWorkspaces.windows)
	.filter(w => w.workspace_id === NiriWorkspaces.activeWorkspace.filter(w => w.output === screen.name).find(w => w.is_active).id)
	.sort((a, b) => {
		if (a.layout.pos_in_scrolling_layout[0] === b.layout.pos_in_scrolling_layout[0]) {
			return a.layout.pos_in_scrolling_layout[1] -b.layout.pos_in_scrolling_layout[1];
		} else return a.layout.pos_in_scrolling_layout[0] -b.layout.pos_in_scrolling_layout[0];
	})

	active: NiriWorkspaces.workspaces
	sourceComponent: Row {
		spacing: 6

		Repeater {
			model: workspaces.length
			delegate: QsButton {
				required property int index

				// get wether this.workspace is active
				readonly property bool isActive: activeWorkspace.idx -1 === index

				anchors.verticalCenter: parent.verticalCenter
				onClicked: Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", index +1]);
				content: Rectangle { id: content
					width: isActive? Math.max(layout.width, 16) : 10
					height: isActive? Math.max(layout.height, 10) : 10
					radius: Math.min(width /2, height /2)
					color: isActive? GlobalVariables.colours.light : GlobalVariables.colours.base
					clip: true
					layer.enabled: true
					layer.effect: OpacityMask {
						maskSource: Rectangle {
							width: content.width
							height: content.height
							radius: content.radius
						}
					}

					// highlight the currently focused column
					Rectangle { id: highlight
						readonly property int activeIdx: windows.findIndex(w => w.layout.pos_in_scrolling_layout[0] === windows.find(w => w.is_focused)?.layout.pos_in_scrolling_layout[0])

						visible: isActive
						x: repeater.itemAt(highlight.activeIdx)?.x || 2 /*+repeater.itemAt(highlight.activeIdx).width /2 -width /2*/
						y: repeater.itemAt(highlight.activeIdx)?.y || 2 /*+repeater.itemAt(highlight.activeIdx).height /2 -height /2*/
						width: repeater.itemAt(highlight.activeIdx)?.width *windows.filter(w => {
							 return w.layout.pos_in_scrolling_layout[0] === windows.find(w => w.is_focused)?.layout.pos_in_scrolling_layout[0]
						}).length
						height: repeater.itemAt(highlight.activeIdx)?.height
						radius: height /2
						color: GlobalVariables.colours.accent

						Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
						Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
					}

					Row { id: layout
						visible: isActive
						anchors.centerIn: parent
						padding: 2
						spacing: 0

						Repeater { id: repeater
							model: ScriptModel {
								values: windows
							}
							delegate: Item {
								required property var modelData

								width: 18
								height: width


								IconImage { id: icon
									anchors.centerIn: parent
									implicitSize: 14
									source: Quickshell.iconPath(modelData.app_id, "window")
								}
							}
						}
					}

					Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic; }}
					Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.OutCubic; }}
				}
			}
		}
	}
}
