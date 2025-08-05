import QtQuick
import QtQuick.Layouts
import Quickshell
import "root:"

Rectangle { id: root
	property bool isFocused: false
	property QtObject style

	width: isFocused? style.focused.width : style.notFocused.width
	height: isFocused? style.focused.height : style.notFocused.height
	radius: isFocused? style.focused.radius : style.notFocused.radius
	color: isFocused? style.focused.color : style.notFocused.color
	gradient: isFocused? style.focused.gradient : style.notFocused.gradient

	Behavior on width { NumberAnimation { duration: 150; }}
	Behavior on height { NumberAnimation { duration: 150; }}
	Behavior on color { ColorAnimation { duration: 150; }}
}
