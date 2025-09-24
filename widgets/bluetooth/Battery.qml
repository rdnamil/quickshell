import QtQuick
import QtQuick.Effects
import Quickshell
import Qt5Compat.GraphicalEffects
import "root:"

Item {
	property real percentage: 1.0
	property bool showPercent: true

	width: 12
	height: 25

	RectangularShadow {
		anchors.fill: healthBar
		offset { x: 0; y: 0; }
		radius: healthBar.radius
		spread: 2
		blur: 2
		color: Qt.darker (healthBar.color, 1.4)
	}

	Rectangle { id: healthBar
		anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 2; }
		width: parent.width -4
		height: (parent.height -5) *percentage
		radius: 1
		color: {
			let health = null
			if (percentage <= 0.15) {
				health = GlobalConfig.colour.red
			} else if (percentage <= 0.33) {
				health = GlobalConfig.colour.orange
			} else {
				health = GlobalConfig.colour.green
			}
			return health;
		}
	}

	Rectangle {
		anchors.bottom: parent.bottom
		width: parent.width
		height: parent.height -1
		radius: 3
		color: "transparent"
		border { width: 1; color: GlobalConfig.colour.foreground; }
		gradient: Gradient {
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
		color: GlobalConfig.colour.foreground
	}
}
