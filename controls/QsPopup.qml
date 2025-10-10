/*---------------------------
--- QsPopup.qml by andrel ---
---------------------------*/

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import "../"

Item { id: root
	required property Item anchor
	required property Item content

	signal closed()

	Rectangle {
		width: anchor.width
		height: anchor.height
		color: "#4000ff00"
	}

	PanelWindow {
		anchors {
			left: true
			right: true
			top: true
			bottom: true
		}
		mask: Region {}
		exclusionMode: ExclusionMode.Ignore
		color: "transparent"

		MouseArea {
			width: screen.width
			height: screen.height
			onClicked: {
				root.closed();
			}
		}
	}

	PopupWindow { id: popup
		visible: true
		anchor {
			item: root;
			rect { x: root.anchor.width /2 -implicitWidth /2; y: root.anchor.height /2 -30; }
		}
		implicitWidth: contentWrapper.width +60
		implicitHeight: contentWrapper.height +60
		color: "#40ff0000"

		RectangularShadow {
			anchors.fill: contentWrapper
			spread: 0
			blur: 30
			radius: GlobalVariables.controls.radius
			opacity: 0.4
		}



		Rectangle { id: contentWrapper
			anchors.centerIn: parent
			width: content.width
			height: content.height
			color: GlobalVariables.colours.dark
			opacity: 0.975
			layer.enabled: true
			layer.effect: OpacityMask {
				maskSource: Rectangle {
					width: contentWrapper.width
					height: contentWrapper.height
					radius: GlobalVariables.controls.radius
				}
			}
		}
	}

	Component.onCompleted: content.parent = contentWrapper;
}
