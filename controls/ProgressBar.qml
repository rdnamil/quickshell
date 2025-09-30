/*-------------------------------
--- ProgressBar.qml by andrel ---
-------------------------------*/

import QtQuick
import "../"
import "../styles"

Item { id: root
	// a value between 0.0 - 1.0
	required property real progress

	// placeholder to avoid warning messages
	property double radius: 0

	// container borders and gradient
	Rectangle {
		anchors.centerIn: parent
		width: parent.width -6
		height: parent.height -6
		radius: parent.radius
		gradient: Gradient {
			orientation: Gradient.Vertical
			GradientStop { position: 0.0; color: "#80000000" }
			GradientStop { position: 1.0; color: "#40000000" }
		}
	}

	Borders { radius: height /2; }

	Rectangle {
		readonly property real fullWidth: parent.width -6	// the max possible width of the progress bar

		anchors {
			left: parent.left
			leftMargin: 3
			verticalCenter: parent.verticalCenter
		}
		// 0=0 else no values less than height or greater than max width
		width: progress > 0? Math.min(Math.max(fullWidth *progress, height), fullWidth) : 0
		height: parent.height -6
		radius: height /2
		color: GlobalVariables.colours.accent

		// progress bar gradient
		Rectangle {
			anchors.fill: parent
			radius: height /2
			gradient: Gradient {
				orientation: Gradient.Vertical
				GradientStop { position: 0.0; color: "#20ffffff" }
				GradientStop { position: 0.1; color: "#80ffffff" }
				GradientStop { position: 0.5; color: "#00000000" }
				GradientStop { position: 1.0; color: "#40000000" }
			}
		}
	}
}
