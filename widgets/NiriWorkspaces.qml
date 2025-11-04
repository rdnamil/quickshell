/*--------------------------------------------
--- NiriWorkspaces.qml - widgets by andrel ---
--------------------------------------------*/

import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.services
import qs.controls

Loader { id: root
	// get list on workspaces on this.screen
	readonly property list<var> workspaces: NiriWorkspaces.workspaces.filter(w => w.output === screen.name)
	// get the current active workspace for this.screen
	readonly property int activeWorkspace: NiriWorkspaces.workspaces.length > 0? NiriWorkspaces.activeWorkspace.filter(w => w.output == screen.name).find(w => w.is_active).idx -1 : 0

	property int workspace
	property list<string> command: ["niri", "msg", "action", "focus-workspace", workspace]

	active: NiriWorkspaces.workspaces
	sourceComponent: Row {
		spacing: 6

		Repeater {
			model: workspaces.length
			delegate: QsButton {
				required property int index

				// get wether this.workspace is active
				readonly property bool isActive: activeWorkspace === index

				onClicked: {
					workspace = index +1;
					Quickshell.execDetached(command)
				}
				content: Rectangle {
					width: isActive? 12 : 8
					height: 8
					radius: height /2
					color: isActive? GlobalVariables.colours.highlightedText : GlobalVariables.colours.midlight

					// add workspace names in future
					Text {
						visible: false
						anchors.centerIn: parent
						text: workspaces.find(w => w.idx === index +1).name
					}

					// animations on change
					Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
					Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic; }}
				}
			}
		}
	}
}
