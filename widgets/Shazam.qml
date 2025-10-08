/*------------------------------------
--- Shazam.qml - widgets by andrel ---
------------------------------------*/

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import "../"
import "../controls"
import "../services"

QsButton { id: root
	anim: false
	shade: false
	onClicked: Shazam.searching? Shazam.stopShazaming() : Shazam.shazam();
	content: IconImage { id: content
		implicitSize: GlobalVariables.controls.iconSize
		source: Quickshell.iconPath("deezer")

		Rectangle {
			visible: Shazam.searching
			anchors.fill: parent
			color: GlobalVariables.colours.shadow
			opacity: 0.7
			layer.enabled: true
			layer.effect: OpacityMask {
				maskSource: IconImage {
					implicitSize: GlobalVariables.controls.iconSize
					source: content.source
				}
			}
		}

		Row {
			visible: Shazam.searching
			spacing: 2
			anchors {
				top: parent.top
				topMargin: parent.height /2 -height /2 +1
				left: parent.left
				leftMargin: parent.width /2 -width /2 +0.5
			}

			Repeater {
				model: 3
				delegate: Rectangle {
					width: 3
					height: width
					radius: height /2
					color: GlobalVariables.colours.text
				}
			}
		}
	}
}
