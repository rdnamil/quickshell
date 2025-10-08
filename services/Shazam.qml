/*-------------------------------------
--- Shazam.qml - services by andrel ---
-------------------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire


Singleton { id: root
	readonly property bool searching: songrec.running

	function shazam() {
		songrec.running = true;
	}

	function stopShazaming() {
		songrec.running = false;
	}

	Process { id: songrec
		running: false
		command: ["songrec", "recognize", "-d", `Monitor of ${Pipewire.defaultAudioSink.description}`]
		stdout: SplitParser {
			onRead: (data) => {
				Notifications.notify("media-tape", "Quickshell", "Shazam", data)
			}
		}
	}
}
