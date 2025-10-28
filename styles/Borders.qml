/*---------------------------
--- Borders.qml by andrel ---
---------------------------*/

import QtQuick
import "../"

Rectangle {
	property bool inverted

	anchors.fill: parent
	radius: parent.radius
	color: "transparent"
	border { color: inverted? GlobalVariables.colours.shadow : GlobalVariables.colours.light; width: 2; }
	// opacity: 0.2

	Rectangle {
		anchors.fill: parent
		radius: parent.radius
		color: "transparent"
		border { color: inverted? GlobalVariables.colours.light : GlobalVariables.colours.shadow; width: 1; }
	}
}
