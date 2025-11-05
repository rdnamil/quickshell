/*--------------------------
--- Slider.qml by andrel ---
--------------------------*/

import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import qs
import qs.controls

Control.Slider { id: root
	wheelEnabled: true
	stepSize: 0.05
	onValueChanged: {
		valueWrapper.visible = true;
		valueTimer.restart();
	}
	background: ProgressBar {
		x: root.leftPadding
		y: root.topPadding + root.availableHeight /2 -height /2
		width: root.availableWidth
		height: 10
		progress: root.visualPosition
	}
	handle: Item {
		x: root.leftPadding +root.visualPosition *(root.availableWidth -4 -width) +2
		y: root.topPadding +root.availableHeight /2 -height /2
		width: height
		height: root.height -4

		Rectangle { id: valueWrapper
			readonly property TextMetrics textMetric: TextMetrics {
				text: "100"
				font: GlobalVariables.font.small
			}

			visible: false
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.verticalCenter
			}
			width: textMetric.width +GlobalVariables.controls.padding
			height: textMetric.height +GlobalVariables.controls.spacing
			radius: GlobalVariables.controls.radius
			color: GlobalVariables.colours.base

			Text {
				anchors.centerIn: parent
				text: parseInt(root.visualPosition *100)
				color: GlobalVariables.colours.text
				font: GlobalVariables.font.small
				horizontalAlignment: Text.AlignHCenter
			}

			Timer { id: valueTimer
				interval: 500
				onTriggered: valueWrapper.visible = false;
			}

			Borders { opacity: 0.4; }
		}
	}
}
