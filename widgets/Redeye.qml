/*------------------------------------
--- Redeye.qml - widgets by andrel ---
------------------------------------*/

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs
import qs.controls
import qs.services as Service

QsButton { id: root
	anim: false
	shade: false
	onClicked: {
		Service.Popout.clear();
		Service.Redeye.toggle();
	}
	content: IconImage { id: widget
		implicitSize: GlobalVariables.controls.iconSize
		source: Service.Redeye.enabled? Quickshell.iconPath("night-light", "night-light-symbolic") : Quickshell.iconPath("night-light-disabled", "night-light-disabled-symbolic")
	}
}
