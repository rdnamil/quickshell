/*------------------
--- Redshift.qml ---
------------------*/

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../"
import "../controls"

QsButton { id: root
	property string startTime
	property string endTime

	property bool enabled

	anim: false
	shade: false
	content: IconImage { id: widget
		implicitSize: GlobalVariables.controls.iconSize
		source: Quickshell.iconPath("night-light")
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
