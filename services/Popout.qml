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
	signal accepted()
	signal keyPressed(KeyEvent event)

	Loader {
		active: whosOpen
		sourceComponent: PanelWindow {
			anchors {
				left: true
				right: true
				top: true
				bottom: true
			}
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
			WlrLayershell.layer: WlrLayer.Top
			color: "transparent"

			TextInput { id: inputField
				focus: true
				onAccepted: root.accepted()
				color: "transparent"
				Keys.onPressed: (event) => {
					if (event.key === Qt.Key_Escape) root.clear();
					else root.keyPressed(event)
				}
			}

			MouseArea {
				anchors.fill: parent
				onClicked: root.clear();
			}
		}
	}
}

