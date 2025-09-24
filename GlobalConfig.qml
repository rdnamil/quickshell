pragma Singleton

import Quickshell
import QtQuick

Singleton { id: root
	readonly property Colour colour: Colour {}
	readonly property Font font: Font {}
	readonly property Weather weather: Weather {}

	readonly property int padding: 10
	readonly property int spacing: 6
	readonly property int cornerRadius: 8

	readonly property int barHeight: 28

	readonly property int iconSize: 16

	readonly property int notificationWidth: 320

	component Colour: QtObject {
		readonly property string foreground: "#cad3f5"
		readonly property string midground: "#6e738d"
		readonly property string background: "#181926"
		readonly property string surface: "#24273a"
		readonly property string accent: "#8aadf4"
		readonly property string red: "#d20f39"
		readonly property string orange: "#f5a97f"
		readonly property string yellow: "#eed49f"
		readonly property string green: "#60bb00"
		readonly property string blue: "#04a5e5"
		readonly property string purple: "#c6a0f6"
		readonly property string aqua: "#8bd5ca"
		readonly property string grey: "#363a4f"
	}

	component Font: QtObject {
		readonly property string sans: "Adwaita Sans"
		readonly property string mono: "JetBrains Mono Nerd Font"
		readonly property int size: 10
		readonly property int regular: 10
		readonly property int small: 8
		readonly property int smaller: 6
		readonly property int thin: 300
		readonly property int semibold: 600
		readonly property int bold: 800
	}

	component Weather: QtObject {
		readonly property string longitude: "46.25"
		readonly property string latitude: "-60.09"
	}
}
