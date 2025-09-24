import QtQuick
import Quickshell
import "root:"

Rectangle { id: root
	width: 1
	height: GlobalConfig.barHeight -GlobalConfig.padding
	color: GlobalConfig.colour.foreground
	opacity: 0.5

	Rectangle {
		anchors.left: parent.right
		width: 1
		height: GlobalConfig.barHeight -GlobalConfig.padding
		color: GlobalConfig.colour.midground
	}
}
