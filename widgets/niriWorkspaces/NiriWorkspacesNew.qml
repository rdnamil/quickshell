pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	readonly property list<var> focusedWorkspace: workspaces.filter(w => w.is_active)

	property list<var> workspaces

	Process { id: eventStream
		running: true
		command: ["niri", "msg", "event-stream"]
		stdout: SplitParser {
			splitMarker: "Workspace"
			onRead: getWorkspaces.running = true
		}
	}

	Process { id: getWorkspaces
		running: true
		command: ["niri", "msg", "--json", "workspaces"]
		stdout: StdioCollector {
			onStreamFinished: workspaces = JSON.parse(text)
		}
	}
}
