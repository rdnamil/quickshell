/*--------------------------
--- Slider.qml by andrel ---
--------------------------*/

import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import qs
import qs.controls

Control.Slider { id: root
	property bool showTooltip: true
	property Item tooltipContent: Text {
		readonly property TextMetrics textMetric: TextMetrics {
			text: "100"
			font: GlobalVariables.font.small
		}

		width: textMetric.width
		height: textMetric.height
		text: parseInt(root.visualPosition *100)
		color: GlobalVariables.colours.text
		font: GlobalVariables.font.small
		horizontalAlignment: Text.AlignHCenter
	}

	wheelEnabled: true
	onValueChanged: if (showTooltip) {
		tooltipWrapper.visible = true;
		tooltipTimer.restart();
	}
	leftPadding: 0
	rightPadding: 0
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

		RectangularShadow {
			visible: tooltipWrapper.visible
			anchors.fill: tooltipWrapper
			offset.y: 2
			radius: tooltipWrapper.radius
			spread: 0
			blur: 12
			color: GlobalVariables.colours.shadow
		}

		Rectangle { id: tooltipWrapper
			visible: false
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.verticalCenter
			}
			width: tooltipContent.width +GlobalVariables.controls.spacing
			height: tooltipContent.height +3
			radius: GlobalVariables.controls.radius
			color: GlobalVariables.colours.base

			Timer { id: tooltipTimer
				interval: 500
				onTriggered: tooltipWrapper.visible = false;
			}

			Borders { opacity: 0.4; }

			Component.onCompleted: {
				tooltipContent.parent = tooltipWrapper;
				tooltipContent.anchors.centerIn = tooltipWrapper;
			}
		}
	}
}
