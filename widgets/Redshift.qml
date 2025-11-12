/*------------------
--- Redshift.qml ---
------------------*/

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs
import qs.controls
import qs.services as Service

QsButton { id: root
	property string startTime
	property string endTime

	property bool enabled

	anim: false
	shade: false
	onClicked: Service.Popout.clear();
	content: IconImage { id: widget
		implicitSize: GlobalVariables.controls.iconSize
		source: Quickshell.iconPath("night-light", "night-light-symbolic")
		layer.enabled: true
		layer.effect: OpacityMask {
			maskSource: IconImage {
				implicitSize: widget.implicitSize
				source: widget.source
			}
		}

		Rectangle {
			visible: root.enabled
			anchors.fill: parent
			color: GlobalVariables.colours.shadow
			opacity: 0.4
		}
	}

	SystemClock { id: clock; precision: SystemClock.Minutes; }
}
