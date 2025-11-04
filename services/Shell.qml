/*------------------------------------
--- Shell.qml - services by andrel ---
------------------------------------*/

import QtQuick
import Quickshell
import Quickshell.Io

pragma Singleton

Singleton { id: root
	readonly property var thisInstance: instances.find(i => i.pid === Quickshell.processId).id

	property list<var> instances

	Process {
		running: true
		command: ["sh", "-c", "qs list -j"]
		stdout: StdioCollector {
			onStreamFinished: instances = JSON.parse(text);
		}
	}

	Connections {
		target: Quickshell

		function onReloadCompleted() {
			Quickshell.inhibitReloadPopup();
			Notifications.notify("hook-notifier", "Quickshell", "Config reload", "Configuration successfully reloaded.");
		}

		function onReloadFailed(errorString) {
			Quickshell.inhibitReloadPopup();
			Notifications.notify("hook-notifier", "Quickshell", "Config reload", `<font color="crimson">${errorString}</font>`);
		}
	}

	IpcHandler {
		target: "shell"
		function reload(): void { Quickshell.reload(); }
	}
}
