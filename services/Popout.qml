/*-------------------------------------
--- Popout.qml - services by andrel ---
-------------------------------------*/

pragma Singleton

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

Singleton { id: root
	readonly property string text: inputField.displayText
	readonly property int cursorPosition: inputField.cursorPosition

	property var whosOpen: null

	function clear() {
		root.whosOpen = null;
		root.open();
		inputField.clear();
	}

	signal open()
	signal accepted()
	signal keyPressed(KeyEvent event)

	PanelWindow {
		visible: whosOpen
		anchors {
			left: true
			right: true
			top: true
			bottom: true
		}
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
		color: "transparent"

		TextInput { id: inputField
			visible: false
			focus: true
			onAccepted: root.accepted()
			Keys.onPressed: (event) => {
				if (event.key === Qt.Key_Escape) root.clear();
				else root.keyPressed(event)
			}
		}

		MouseArea {
			anchors.fill: parent
			onClicked: root.clear();
			focus: true
		}
	}
}

