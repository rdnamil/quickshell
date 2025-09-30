/*--------------------------------------
--- Battery.qml - controls by andrel ---
--------------------------------------*/

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import "../"

Item { id: root
	property real percentage: 1.0
	property bool isCharging
	property bool material

	width: 12
	height: 24

	RectangularShadow {
		visible: !root.material
		anchors.fill: healthBar
		offset { x: 0; y: 0; }
		radius: healthBar.radius
		spread: 2
		blur: 2
		color: Qt.darker (healthBar.color, 1.25)
	}

	Rectangle { id: healthBar
		anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 2; }
		width: parent.width -4
		height: (parent.height -5) *percentage
		radius: 1
		color: switch (Math.round(percentage /(1 /6)) *(1 /6)) {
			case 1 /6:
				return "red";
			case 2 /6:
				return "orange";
			default:
				return "forestgreen";
		}
	}

	Text {
		visible: isCharging
		anchors.centerIn: overlay
		text: "󱐋"
		color: GlobalVariables.colours.text
		font.pixelSize: parent.width
		rotation: -root.rotation
	}

	Rectangle { id: overlay
		anchors.bottom: parent.bottom
		width: parent.width
		height: parent.height -1
		radius: 3
		color: "transparent"
		border { width: 1; color: GlobalVariables.colours.text; }
		gradient: { if (!material) return sku;}

		Gradient { id: sku
			orientation: Gradient.Horizontal
			GradientStop { position: 0.0; color: "#20000000" }
			GradientStop { position: 0.1; color: "#80ffffff" }
			GradientStop { position: 0.5; color: "#00000000" }
			GradientStop { position: 1.0; color: "#40000000" }
		}


	}

	Rectangle {
		anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; }
		width: 4
		height: 1
		color: GlobalVariables.colours.text
	}
}

