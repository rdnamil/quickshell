import QtQuick
import Quickshell
import "root:"

Rectangle { id: root
	property real fill

	radius: height /2
	border { color: "#60000000"; width: 1; }
	gradient: Gradient {
		orientation: Gradient.Vertical
		GradientStop { position: 0.0; color: "#60000000" }
		GradientStop { position: 1.0; color: "#30000000" }
	}

	Rectangle { id: fillBar
		readonly property int fillLength: parent.width *fill -2

		anchors { left: parent.left; leftMargin: 1; verticalCenter: parent.verticalCenter; }
		width: fill === 0? 0 : Math.max(height,Math.min(fillLength, root.width -2))
		height: parent.height -2
		radius: height /2
		color: GlobalConfig.colour.accent

		Rectangle { id: fillBarOverlay
			anchors.fill: parent
			radius: height /2
			gradient: Gradient {
				orientation: Gradient.Vertical
				GradientStop { position: 0.0; color: "#20000000" }
				GradientStop { position: 0.1; color: "#80ffffff" }
				GradientStop { position: 0.5; color: "#00000000" }
				GradientStop { position: 1.0; color: "#40000000" }
			}
		}
	}
}
