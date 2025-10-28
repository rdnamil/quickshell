/*-------------------------------------
--- Popout.qml - services by andrel ---
-------------------------------------*/

pragma Singleton

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

Singleton { id: root
	property var whosOpen: null

	function clear() {
		root.whosOpen = null;
		root.open();
	}

	signal open()

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

		MouseArea {
			anchors.fill: parent
			onClicked: root.clear();
			focus: true
			Keys.onPressed: (event) => { if (event.key === Qt.Key_Escape) root.clear(); }
		}
	}
}

