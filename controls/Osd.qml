/*-----------------------
--- OSD.qml by andrel ---
-----------------------*/

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../"

Item { id: root
	required property Item content

	property bool shouldShow

	function showOsd() {
		root.shouldShow = true;
		hideTimer.restart();
	}

	Timer { id: hideTimer
		running: false
		interval: 1000
		onTriggered: root.shouldShow = false;
	}

	LazyLoader {
		active: root.shouldShow

		PanelWindow {
			WlrLayershell.layer: WlrLayer.Overlay
			mask: Region {}
			implicitWidth: content.width +60
			implicitHeight: content.height +60
			color: "transparent"

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
				radius: GlobalVariables.controls.radius
				color: GlobalVariables.colours.dark
				opacity: 0.975
				layer.enabled: true
				layer.effect: OpacityMask {
					maskSource: Rectangle {
						width: content.width
						height: content.height
						radius: GlobalVariables.controls.radius
					}
				}
			}

			Component.onCompleted: { content.parent = contentWrapper; }
		}
	}
}
