/*-----------------------------------
--- GlobalVariables.qml by andrel ---
-----------------------------------*/

pragma Singleton

import QtQuick
import Quickshell

Singleton { id: root
	readonly property var controls: QtObject {
		readonly property int padding: 10
		readonly property int spacing: 8
		readonly property int radius: 8
		readonly property int barHeight: 38
		readonly property int iconSize: 16
		readonly property string terminal: "ghostty"
	}
	readonly property var font: QtObject {
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
		readonly property font italic: Qt.font({
			family: "Adwaita Sans",
			pointSize: 10,
			italic: true
		})
		readonly property font mono: Qt.font({
			family: "JetBrainsMono Nerd Font",
			pointSize: 10
		})
		readonly property font small: Qt.font({
			family: "Adwaita Sans",
			pointSize: 8
		})
		readonly property font smallitalics: Qt.font({
			family: "Adwaita Sans",
			pointSize: 8,
			italic: true
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
		readonly property font monosmall: Qt.font({
			family: "JetBrainsMono Nerd Font",
			pointSize: 8,
		})
		readonly property font smaller: Qt.font({
			family: "Adwaita Sans",
			pointSize: 6,
			weight: 600,
			letterSpacing: 0.5
		})
		readonly property font smalleritalics: Qt.font({
			family: "Adwaita Sans",
			pointSize: 6,
			letterSpacing: 0.5,
			italic: true
		})
		readonly property font monosmaller: Qt.font({
			family: "JetBrainsMono Nerd Font",
			pointSize: 6,
			weight: 600,
			letterSpacing: 0.5
		})
	}
	readonly property SystemPalette colours: SystemPalette { colorGroup: SystemPalette.Active; }
}
