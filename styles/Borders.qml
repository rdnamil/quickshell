/*---------------------------
--- Borders.qml by andrel ---
---------------------------*/

import QtQuick
import "../"

Rectangle {
	property bool inverted

	anchors.fill: parent
	topLeftRadius: parent.topLeftRadius
	topRightRadius: parent.topRightRadius
	bottomLeftRadius: parent.bottomLeftRadius
	bottomRightRadius: parent.bottomRightRadius
	color: "transparent"
	border { color: inverted? GlobalVariables.colours.shadow : GlobalVariables.colours.light; width: 2; }
	// opacity: 0.2

	Rectangle {
		anchors.fill: parent
		topLeftRadius: parent.topLeftRadius
		topRightRadius: parent.topRightRadius
		bottomLeftRadius: parent.bottomLeftRadius
		bottomRightRadius: parent.bottomRightRadius
		color: "transparent"
		border { color: inverted? GlobalVariables.colours.light : GlobalVariables.colours.shadow; width: 1; }
	}
}
