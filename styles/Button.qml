/*----------------
--- Button.qml ---
----------------*/

import QtQuick
import Qt5Compat.GraphicalEffects
import "../"

Rectangle { id: root
	property bool inverted

	width: GlobalVariables.controls.iconSize +GlobalVariables.controls.spacing
	height: width
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
		visible: !inverted
		anchors.fill: parent
		gradient: Gradient {
			orientation: Gradient.Vertical
			GradientStop { position: 0.0; color: "#20000000" }
			GradientStop { position: 1.0; color: "#40000000" }
		}
	}

	Rectangle {
		visible: inverted
		anchors.fill: parent
		gradient: Gradient {
			orientation: Gradient.Vertical
			GradientStop { position: 0.0; color: "#80000000" }
			GradientStop { position: 1.0; color: "#40000000" }
		}
	}

	Borders { opacity: 0.75; }
}
