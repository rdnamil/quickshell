/*-----------------------------
--- QsTooltip.qml by andrel ---
-----------------------------*/

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import "../"
import "../styles"

Item { id: root
	required property Item anchor
	required property Item content

	property bool isShown

	anchors.fill: anchor

	Loader {
		active: content
		sourceComponent: PopupWindow {
			visible: isShown
			anchor {
				item: root
				rect { x: root.width /2 -content.width /2 -GlobalVariables.controls.padding /2; y: root.height +2; }
			}
			implicitWidth: content.width +GlobalVariables.controls.padding
			implicitHeight: content.height +GlobalVariables.controls.padding
			color: "transparent"

			Rectangle { id: contentWrapper
				anchors.fill: parent
				radius: GlobalVariables.controls.radius
				color: GlobalVariables.colours.base
				layer.enabled: true
				layer.effect: OpacityMask {
					maskSource: Rectangle {
						width: contentWrapper.width
						height: contentWrapper.height
						radius: contentWrapper.radius
					}
				}

				Borders { opacity: 0.4; }
			}

			Component.onCompleted: {
				content.parent = contentWrapper;
				content.anchors.centerIn = contentWrapper;
			}
		}
	}
}
