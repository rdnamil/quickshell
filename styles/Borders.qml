/*---------------------------
--- Borders.qml by andrel ---
---------------------------*/

import QtQuick
import "../"

Rectangle {
	anchors.fill: parent
	radius: parent.radius
	color: "transparent"
	border { color: GlobalVariables.colours.light; width: 2; }
	opacity: 0.2

	Rectangle {
		anchors.fill: parent
		radius: parent.radius
		color: "transparent"
		border { color: GlobalVariables.colours.shadow; width: 1; }
	}
}
