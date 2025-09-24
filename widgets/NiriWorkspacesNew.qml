import QtQuick
import Quickshell
import Quickshell.Io
import "../"
import "../tools"
import "niriWorkspaces"

Row { id: root
	readonly property list<var> workspaces: NiriWorkspacesNew.workspaces.filter(w => w.output === screen.name)
	readonly property int focusedWorkspace: NiriWorkspacesNew.focusedWorkspace.filter(w => w.output == screen.name).find(w => w.is_active).idx -1

	spacing: 2

	Repeater {
		model: workspaces.length

		SimpleButton { id: pill
			required property var modelData
			required property int index

			onClicked: {
				focusOn.command = ["niri", "msg", "action", "focus-workspace", index +1];
				focusOn.running = true;
			}
			content: Rectangle {
				width: focusedWorkspace === index? 12 : 8
				height: 8
				radius: height /2
				color: focusedWorkspace === index? GlobalConfig.colour.foreground : GlobalConfig.colour.surface

				Text {
					visible: false
					anchors.centerIn: parent
					text: workspaces.find(w => w.idx === index +1).name
				}

				Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
				Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic; }}
			}
		}
	}

	Process { id: focusOn
		running: false
	}
}
