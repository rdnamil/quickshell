/*-------------------------------------
--- Popout.qml - services by andrel ---
-------------------------------------*/

pragma Singleton

import QtQuick
import QtQuick.Controls
import Quickshell

Singleton { id: root
	property var whosOpen: null

	signal open()

	PanelWindow {
		visible: whosOpen
		anchors {
			left: true
			right: true
			top: true
			bottom: true
		}
		color: "transparent"

		MouseArea {
			anchors.fill: parent
			onClicked: {
				root.whosOpen = null;
				root.open();
			}
		}
	}
}

