/*-------------------------
--- Clock.qml by andrel ---
-------------------------*/

import QtQuick
import Quickshell
import qs

Row { id: root
	spacing: 4

	SystemClock { id: clock
		precision: SystemClock.Seconds
	}

	// date
	Text {
		text: Qt.formatDateTime(clock.date, "ddd d")
		color: GlobalVariables.colours.windowText
		font : GlobalVariables.font.regular
	}

	// devider
	Rectangle {
		anchors.verticalCenter: parent.verticalCenter
		width: 4
		height: width
		radius: height /2
		color: GlobalVariables.colours.text
	}

	// time
	Text {
		text: Qt.formatDateTime(clock.date, "hh:mm")
		color: GlobalVariables.colours.text
		font: GlobalVariables.font.semibold
	}
}
