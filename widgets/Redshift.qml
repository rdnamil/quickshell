/*------------------
--- Redshift.qml ---
------------------*/

import QtQuick
import Quickshell
import Quickshell.Widgets
// import Quickshell.Io
import qs
import qs.controls
import qs.services as Service

QsButton { id: root
	anim: false
	shade: false
	onClicked: {
		Service.Popout.clear();
		Service.Redshift.toggle();
	}
	content: IconImage { id: widget
		implicitSize: GlobalVariables.controls.iconSize
		source: Service.Redshift.enabled? Quickshell.iconPath("night-light", "night-light-symbolic") : Quickshell.iconPath("night-light-disabled", "night-light-disabled-symbolic")
	}
}
