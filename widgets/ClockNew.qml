/*----------------------------
--- Clock widget by andrel ---
----------------------------*/

import QtQuick
import Quickshell
import "root:"

Row { id: root
	property string timeFormat: "hh:mm"
	property string dateFormat: "ddd d"

	spacing: GlobalConfig.spacing

	SystemClock { id: clock
		precision: SystemClock.Seconds
	}

	Text {
		text: Qt.formatDateTime(clock.date, dateFormat)
		color: GlobalConfig.colour.midground
		font {
			family: GlobalConfig.font.setAttributeNS
			pointSize: GlobalConfig.font.regular
			// weight: GlobalConfig.font.thin
		}
	}

	Rectangle {
		anchors.verticalCenter: parent.verticalCenter
		width: 4
		height: width
		radius: height /2
		color: GlobalConfig.colour.foreground
	}

	Text {
		text: Qt.formatDateTime(clock.date, timeFormat)
		color: GlobalConfig.colour.foreground
		font {
			family: GlobalConfig.font.setAttributeNS
			pointSize: GlobalConfig.font.regular
			weight: GlobalConfig.font.semibold
		}
	}
}
