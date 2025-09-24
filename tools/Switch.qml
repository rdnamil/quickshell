import QtQuick
import QtQuick.Effects
import Quickshell
import "root:"

Item { id: root
	property bool isOn: false

	signal clicked()
	signal toggled()

	width: 32
	height: 20

	Rectangle {
		anchors.fill: parent
		radius: height /2
		color: isOn? GlobalConfig.colour.green : GlobalConfig.colour.midground
		border { width: 1; color: "#40000000"; }
		Behavior on color { ColorAnimation { duration: 100; easing.type: Easing.InCirc; }}
	}

	RectangularShadow { id: shadow
		anchors.fill: button
		offset.x: 0
		offset.y: 4
		spread: 0
		blur: 8
		color: "black"
	}

	Rectangle { id: button
		anchors.verticalCenter: parent.verticalCenter
		width: root.height -4
		height: root.height -4
		radius: height /2
		color: GlobalConfig.colour.foreground
		x: isOn? root.width -(width +2) : 2
		Behavior on x { NumberAnimation { duration: 100; easing.type: Easing.InCirc; }}
	}

	MouseArea {
		anchors.fill: parent
		onClicked: root.clicked()
	}

	function toggle() {
		if (root.isOn) {
			root.isOn = false;
		} else {
			root.isOn = true;
		}
		toggled();
	}
}
