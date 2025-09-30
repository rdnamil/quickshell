/*-----------------------------
--- Seperator.qml by andrel ---
-----------------------------*/

import QtQuick
import "../"

Rectangle { id: root
	width: 2
	height: GlobalVariables.controls.barHeight -GlobalVariables.controls.padding
	color: GlobalVariables.colours.light
	opacity: 0.4

	Rectangle {
		anchors.right: parent.right
		width: 1
		height: GlobalVariables.controls.barHeight -GlobalVariables.controls.padding
		color: GlobalVariables.colours.shadow
	}
}
