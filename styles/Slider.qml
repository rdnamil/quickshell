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
	}

	// handle: Item {
	// 	x: root.leftPadding +root.visualPosition *(root.availableWidth -width)
	// 	y: root.topPadding +root.availableHeight /2 -height /2
	// 	width: GlobalVariables.controls.iconSize
	// 	height: width
 //
	// 	RectangularShadow {
	// 		anchors.fill: handle
	// 		radius: handle.radius
	// 		spread: 1
	// 		blur: 3
	// 		color: GlobalVariables.colours.shadow
	// 		opacity: 0.4
	// 	}
 //
	// 	Rectangle { id: handle
	// 		width: parent.width
	// 		height: parent.height
	// 		radius: width /2
	// 		color: (root.hovered || root.pressed)? GlobalVariables.colours.accent : GlobalVariables.colours.midlight
	// 		// border { width: 1; color: "#10000000"; }
	// 		layer.enabled: true
	// 		layer.effect: DropShadow {
	// 			color: GlobalVariables.colours.light
	// 			spread: 0
	// 			radius: 0
	// 			samples: 1
	// 			verticalOffset: -1
	// 		}
	// 	}
	// }
}
