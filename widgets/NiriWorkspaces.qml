/*--------------------------------------------
--- NiriWorkspaces.qml - widgets by andrel ---
--------------------------------------------*/

import QtQuick
import QtQuick.Effects
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
	.filter(w => w.layout.pos_in_scrolling_layout)
	.sort((a, b) => {
		if (a.layout.pos_in_scrolling_layout[0] === b.layout.pos_in_scrolling_layout[0]) {
			return a.layout.pos_in_scrolling_layout[1] -b.layout.pos_in_scrolling_layout[1];
		} else return a.layout.pos_in_scrolling_layout[0] -b.layout.pos_in_scrolling_layout[0];
	})

	property bool isMaterial
	property bool noTasks

	active: NiriWorkspaces.workspaces
	sourceComponent: Row {
		spacing: 6

		Repeater {
			model: workspaces.length
			delegate: QsButton { id: workspace
				required property int index

				// get wether this.workspace is active
				readonly property bool isActive: activeWorkspace.idx -1 === index

				anchors.verticalCenter: parent.verticalCenter
				onClicked: Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", index +1]);
				content: Rectangle { id: content
					width: isActive? Math.max(layout.width, 16) : 10
					height: isActive? Math.max(layout.height, 10) : 10
					radius: Math.min(width /2, height /2) -1
					color: isActive? (repeater.count > 0? GlobalVariables.colours.light : GlobalVariables.colours.text) : GlobalVariables.colours.mid

					// Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
					// Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
					Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.OutCubic; }}

					Rectangle {
						visible: isActive && repeater.count > 0
						anchors.fill: parent
						radius: height /2
						gradient: Gradient {
							orientation: Gradient.Vertical
							GradientStop { position: 0.0; color: "#80000000" }
							GradientStop { position: 1.0; color: "#40000000" }
						}
						opacity: 0.4
					}
				}
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
					readonly property int windowsInCol: windows.filter(w => {
						return w.layout.pos_in_scrolling_layout[0] === windows.find(w => w.is_focused)?.layout.pos_in_scrolling_layout[0]
					}).length

					visible: isActive && repeater.itemAt(highlight.activeIdx)
					x: repeater.itemAt(highlight.activeIdx)?.x || 3 /*+repeater.itemAt(highlight.activeIdx).width /2 -width /2*/
					y: repeater.itemAt(highlight.activeIdx)?.y +(root.isMaterial? 0 : 1) || 4 /*+repeater.itemAt(highlight.activeIdx).height /2 -height /2*/
					width: repeater.itemAt(highlight.activeIdx)?.width *windowsInCol +layout.spacing *(windowsInCol -1)
					height: repeater.itemAt(highlight.activeIdx)?.height -(root.isMaterial? 0 : 1)
					radius: height /2
					color: GlobalVariables.colours.highlight
					layer.enabled: true
					layer.effect: MultiEffect {
						shadowEnabled: !root.isMaterial
						shadowColor: GlobalVariables.colours.text
						// shadowColor: "red"
						shadowBlur: 0.03
						shadowVerticalOffset: -1
						shadowOpacity: 1.0
						saturation: 1.0
					}

					Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
					Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
				}

				Row { id: layout
					visible: isActive
					anchors.centerIn: parent
					padding: 3
					spacing: GlobalVariables.controls.spacing *1 /4

					width: implicitWidth

					Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}

					Repeater { id: repeater
						model: noTasks? 0 : windows
						delegate: QsButton {
							required property var modelData

							width: GlobalVariables.controls.iconSize +4
							height: width
							tooltip: Text {
								text: modelData.title
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.regular
							}
							onClicked: {
								Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", modelData.id]);
								Quickshell.execDetached(["niri", "msg", "action", "center-column"]);
							}
							content: Item {
								anchors.centerIn: parent
								width: GlobalVariables.controls.iconSize
								height: width

								RectangularShadow {
									visible: !root.isMaterial
									anchors.fill: window
									offset.y: 2
									spread: -3
									blur: 6
									radius: height /2
									color: GlobalVariables.colours.shadow
								}

								IconImage { id: window
									implicitSize: parent.width
									source: Quickshell.iconPath(DesktopEntries.byId(modelData.app_id).name.toLowerCase(), true) || Quickshell.iconPath(modelData.app_id, "image-missing")
								}
							}
						}
					}
				}
			}
		}
	}
}
