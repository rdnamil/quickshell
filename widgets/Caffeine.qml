/*-------------------------------
--- Caffeine widget by andrel ---
-------------------------------*/

import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import ".."
import "../tools"

SimpleButton { id: root
	property bool isCaffeine: inhibitor.running

	darken: false
	animate: false
	onClicked: inhibitor.running = !inhibitor.running;
	content: IconImage {
		implicitSize: GlobalConfig.iconSize
		source: isCaffeine? Quickshell.iconPath("my-caffeine-on") : Quickshell.iconPath("my-caffeine-off")
	}

	Process { id: inhibitor
		running: false
		command: ["systemd-inhibit", "--what=idle", "--who=Caffeine", "--why=Caffeine", "--mode=block", "sleep", "inf"]
	}
}
