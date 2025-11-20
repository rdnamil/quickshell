/*---------------------------------------------
--- NiriWorkspaces.qml - services by andrel ---
---------------------------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	// filter for only active workspaces
	readonly property list<var> activeWorkspace: workspaces.filter(w => w.is_active)

	// list of all niri workspaces
	property list<var> workspaces: []

	// list of all windows
	property list<var> windows: []

	// update list on a 'workspace' event
	Process { id: eventStream
		running: true
		command: ["niri", "msg", "event-stream"]
		stdout: SplitParser {
			// splitMarker: "Workspace"
			onRead: {
				getWorkspaces.running = true
				getWindows.running = true
			}
		}
	}

	Process { id: getWorkspaces
		running: true
		command: ["niri", "msg", "--json", "workspaces"]
		stdout: StdioCollector {
			onStreamFinished: workspaces = JSON.parse(text)
		}
	}

	Process { id: getWindows
		running: true
		command: ["niri", "msg", "--json", "windows"]
		stdout: StdioCollector {
			onStreamFinished: windows = JSON.parse(text)
		}
	}
}
