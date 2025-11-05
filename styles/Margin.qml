/*--------------------------
--- Margin.qml by andrel ---
--------------------------*/

import QtQuick
import qs

Item { id: root
	property bool isVertical

	height: 2
	width: 2

	Rectangle {
		anchors.centerIn: parent
		width: parent.width -GlobalVariables.controls.padding *2
		height: 2
		color: GlobalVariables.colours.light

		Rectangle {
			anchors.bottom: parent.bottom
			width: parent.width
			height: 1
			color: GlobalVariables.colours.shadow
		}
	}
}
