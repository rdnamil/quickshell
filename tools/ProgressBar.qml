import QtQuick
import Quickshell
import "root:"

Item { id: root
	property real fill

	Rectangle { id: backBar
		width: root.width
		height: root.height
		radius: height /2
		border { color: "#60000000"; width: 1; }
		gradient: Gradient {
			orientation: Gradient.Vertical
			GradientStop { position: 0.0; color: "#60000000" }
			GradientStop { position: 1.0; color: "#30000000" }
		}
	}

	Rectangle { id: fillBar
		readonly property int fillLength: backBar.width *fill

		anchors { left: backBar.left; leftMargin: 1; verticalCenter: backBar.verticalCenter; }
		width: fillLength -2 < height? height : fillLength -2
		height: backBar.height -2
		radius: height /2
		color: GlobalConfig.colour.accent
	}

	Rectangle { id: fillBarOverlay
		anchors.fill: fillBar
		radius: height /2
		gradient: Gradient {
			orientation: Gradient.Vertical
			GradientStop { position: 0.0; color: "#80ffffff" }
			GradientStop { position: 0.5; color: "#00000000" }
			GradientStop { position: 1.0; color: "#40000000" }
		}
	}
}
