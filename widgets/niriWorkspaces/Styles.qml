pragma Singleton

import Quickshell
import QtQuick
import "root:"

Singleton { id: root

	readonly property Style named: Style { id: named
		text: true
		focused: Rectangle {
			width: 16
			height: 16
			radius: 4
			color: GlobalConfig.colour.accent
		}

		notFocused: Rectangle {
			width: 16
			height: 16
			radius: 4
			color: GlobalConfig.colour.grey
		}
	}

	readonly property Style pills: Style { id: pills
		text: false
		focused: Rectangle {
			width: 12
			height: 8
			radius: height /2
			color: GlobalConfig.colour.foreground
		}

		notFocused: Rectangle {
			width: 8
			height: 8
			radius: height /2
			color: GlobalConfig.colour.grey
		}
	}

	component Style: QtObject {
		property bool text
		property Rectangle focused
		property Rectangle notFocused
	}
}
