/*-----------------------------------
--- GlobalVariables.qml by andrel ---
-----------------------------------*/

pragma Singleton

import QtQuick
import Quickshell

Singleton { id: root
	readonly property QtObject controls: QtObject {
		readonly property int padding: 10
		readonly property int spacing: 8
		readonly property int radius: 8
		readonly property int barHeight: 32
		readonly property int iconSize: 16
		readonly property int notificationWidth: 320
	}
	readonly property QtObject font: QtObject {
		readonly property font regular: Qt.font({
			family: "Adwaita Sans",
			pointSize: 10
		})
		readonly property font semibold: Qt.font({
			family: "Adwaita Sans",
			pointSize: 10,
			weight: 600
		})
		readonly property font bold: Qt.font({
			family: "Adwaita Sans",
			pointSize: 10,
			weight: 800
		})
		readonly property font small: Qt.font({
			family: "Adwaita Sans",
			pointSize: 8
		})
		readonly property font smallsemibold: Qt.font({
			family: "Adwaita Sans",
			pointSize: 8,
			weight: 600
		})
		readonly property font smallbold: Qt.font({
			family: "Adwaita Sans",
			pointSize: 8,
			weight: 800
		})
		readonly property font smaller: Qt.font({
			family: "Adwaita Sans",
			pointSize: 6,
			weight: 600,
			letterSpacing: 0.5
		})
		readonly property font monosmaller: Qt.font({
			family: "Adwaita Sans Mono",
			pointSize: 6,
			weight: 600,
			letterSpacing: 0.5
		})
	}
	readonly property SystemPalette colours: SystemPalette { colorGroup: SystemPalette.Active; }
	readonly property QtObject weather: QtObject {
		readonly property string longitude: "46.25"
		readonly property string latitude: "-60.09"
	}
}
