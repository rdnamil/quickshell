/*----------------------------
--- Caffeine.qml by andrel ---
----------------------------*/

import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs
import qs.controls
import qs.services as Service

QsButton { id: root
	property bool isCaffeine: inhibitor.running

	anim: false
	shade: false
	onClicked: {
		 inhibitor.running = !inhibitor.running;
		 Service.Popout.clear();
	}
	content: IconImage {
		implicitSize: GlobalVariables.controls.iconSize
		source: isCaffeine? Quickshell.iconPath("caffeine-cup-full", "my-caffeine-on") : Quickshell.iconPath("caffeine-cup-empty", "my-caffeine-off")
	}

	Process { id: inhibitor
		running: false
		command: ["systemd-inhibit", "--what=idle", "--who=Caffeine", "--why=Caffeine", "--mode=block", "sleep", "inf"]
	}
}
