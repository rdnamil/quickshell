/*----------------------------------------
--- Niri workspaces service by andrel ---*
----------------------------------------*/

pragma Singleton

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Singleton { id: root
	property int numWorkspaces
	property int focusedWorkspace

	signal spaceAdded()
	signal spaceRemoved()

	Process {
		running: true
		command: ["niri", "msg", "event-stream"]
		stdout: SplitParser {
			splitMarker: "Workspace"
			onRead: getWorkspace.running = true
		}
	}

	Process { id: getWorkspace
		running: true
		command: ["niri", "msg", "workspaces"]
		stdout: StdioCollector {
			onStreamFinished: {
				let totalSpaces = parseInt((text.trim().split('\n').pop()).match(/\d+/)?.[0], 10);
				if (totalSpaces > root.numWorkspaces) {
					spaceAdded();
				} else if (totalSpaces < root.numWorkspaces) {
					spaceRemoved();
				}
				root.numWorkspaces = totalSpaces;
				root.focusedWorkspace = parseInt((text.split('\n').find(line => line.includes('*'))).match(/\d+/)?.[0], 10);
			}
		}
	}
}
