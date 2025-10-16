/*------------------------------
--- Bar_Style2.qml by andrel ---
------------------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland

PanelWindow { id: root
	required property var modelData

	property list<Item> leftItems
	property list<Item> centreItems
	property list<Item> rightItems

	screen: modelData
	anchors {
		left: true
		right: true
		top: true
	}
	exclusionMode: ExclusionMode.Ignore
	mask: Region {}
	implicitHeight: parent.height +30
	color: "transparent"

	// draw shadow bellow bar outide mask region
	Rectangle { id: barClone
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: GlobalVariables.controls.padding
		}
		width: screen.width -GlobalVariables.controls.padding *2
		height: GlobalVariables.controls.barHeight
		radius: height /4
		color: "transparent"
	}

	RectangularShadow {
		anchors.fill: barClone
		radius: barClone.radius
		spread: 0
		blur: 30
		opacity: 0.4
	}

	// draw bar and set mouse region
	PanelWindow {
		anchors {
			left: true
			right: true
			top: true
		}
		mask: Region { item: bar; }
		implicitHeight: GlobalVariables.controls.barHeight +GlobalVariables.controls.spacing
		color: "transparent"

		Rectangle { id: bar
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
			}
			width: screen.width -GlobalVariables.controls.padding *2
			height: GlobalVariables.controls.barHeight +2
			radius: height /4
			color: GlobalVariables.colours.dark
			border { width: 2; color: GlobalVariables.colours.light; }

			Rectangle {
				anchors.fill: parent
				radius: parent.radius
				color: "transparent"
				border { width: 1; color: GlobalVariables.colours.shadow; }
			}

			// section bar into left, right, and centre for widget placement
			Row { id: left
				anchors.verticalCenter: parent.verticalCenter
				spacing: GlobalVariables.controls.spacing
				leftPadding: GlobalVariables.controls.padding
			}

			Row { id: centre
				anchors {
					centerIn: parent
					verticalCenter: parent.verticalCenter
				}
				spacing: GlobalVariables.controls.spacing
			}

			Row { id: right
				anchors {
					right: parent.right
					verticalCenter: parent.verticalCenter
				}
				rightPadding: GlobalVariables.controls.padding
				spacing: GlobalVariables.controls.spacing
			}
		}
	}

	Component.onCompleted: {
		for (var item of leftItems) { item.parent = left; item.anchors.verticalCenter = left.verticalCenter; }
		for (var item of centreItems) { item.parent = centre; item.anchors.verticalCenter = centre.verticalCenter; }
		for (var item of rightItems) { item.parent = right; item.anchors.verticalCenter = right.verticalCenter; }
	}
}
