/*----------------------------
--- QsSwitch.qml by andrel ---
----------------------------*/

import QtQuick
import QtQuick.Effects
import Quickshell
import "../"

Item { id: root
	property bool isOn: false

	signal clicked()
	signal toggled()

	function toggle() {
		if (root.isOn) {
			root.isOn = false;
		} else {
			root.isOn = true;
		}
		toggled();
	}

	width: 32
	height: 20

	Rectangle {
		anchors.fill: parent
		radius: height /2
		color: isOn? "limegreen" : GlobalVariables.colours.light
		border { width: 1; color: "#10000000"; }
		Behavior on color { ColorAnimation { duration: 100; easing.type: Easing.InCirc; }}
	}

	RectangularShadow { id: shadow
		anchors.fill: button
		offset.x: 0
		offset.y: 4
		spread: 0
		blur: 8
		color: GlobalVariables.colours.shadow
	}

	Rectangle { id: button
		anchors.verticalCenter: parent.verticalCenter
		width: root.height -2
		height: root.height -2
		radius: height /2
		color: GlobalVariables.colours.highlightedText
		border { width: 1; color: "#10000000"; }
		x: isOn? root.width -(width +1) : 1
		Behavior on x { NumberAnimation { duration: 100; easing.type: Easing.InCirc; }}
	}

	MouseArea {
		anchors.fill: parent
		onClicked: root.clicked()
	}
}
