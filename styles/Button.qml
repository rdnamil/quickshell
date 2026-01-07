/*----------------
--- Button.qml ---
----------------*/

import QtQuick
import Qt5Compat.GraphicalEffects
import qs

Rectangle { id: root
	property bool invert

	width: GlobalVariables.controls.iconSize +GlobalVariables.controls.spacing
	height: GlobalVariables.controls.iconSize +GlobalVariables.controls.spacing
	radius: 6
	color: GlobalVariables.colours.midlight
	layer.enabled: true
	layer.effect: OpacityMask {
		maskSource: Rectangle {
			width: root.width
			height: root.height
			radius: root.radius
		}
	}

	Rectangle {
		visible: !invert
		anchors.fill: parent
		gradient: Gradient {
			orientation: Gradient.Vertical
			GradientStop { position: 0.0; color: "#20000000" }
			GradientStop { position: 1.0; color: "#40000000" }
		}
	}

	Rectangle {
		visible: invert
		anchors.fill: parent
		gradient: Gradient {
			orientation: Gradient.Vertical
			GradientStop { position: 0.5; color: "#80000000" }
			GradientStop { position: 1.0; color: "#60000000" }
		}
	}

	Borders { opacity: 0.75; }
}
