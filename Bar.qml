/*-----------------------
--- Bar.qml by andrel ---
-----------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell

PanelWindow { id: root
	required property var modelData

	property list<Item> leftItems
	property list<Item> centreItems
	property list<Item> rightItems

	property int barHeight: GlobalVariables.controls.barHeight

	anchors {
		left: true
		right: true
		top: true
	}
	screen: modelData
	implicitHeight: barHeight
	color: "transparent"

	Rectangle {
		anchors.fill: parent
		color: GlobalVariables.colours.dark
		opacity: 0.975

		// margin line
		Rectangle {
			anchors.bottom: parent.bottom
			width: parent.width
			height: 1
			color: GlobalVariables.colours.light
			// opacity: 0.4
		}

		// round bar corners
		Rectangle {
			anchors.left: parent.left
			width: GlobalVariables.controls.barHeight
			height: width
			color: "black"
			layer.enabled: true
			layer.effect: OpacityMask {
				invert: true
				maskSource: Rectangle {
					width: GlobalVariables.controls.barHeight
					height: width
					topLeftRadius: height /3
				}
			}
		}

		Rectangle {
			anchors.right: parent.right
			width: GlobalVariables.controls.barHeight
			height: width
			color: "black"
			layer.enabled: true
			layer.effect: OpacityMask {
				invert: true
				maskSource: Rectangle {
					width: GlobalVariables.controls.barHeight
					height: width
					topRightRadius: height /3
				}
			}
		}
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

	// draw shadow bellow bar outide exclusion zone
	PanelWindow {
		anchors {
			left: true
			right: true
			top: true
		}
		margins.top: GlobalVariables.controls.barHeight
		exclusionMode: ExclusionMode.Ignore
		mask: Region {}
		implicitHeight: 30
		color: "transparent"

		RectangularShadow {
			anchors.fill: margin
			spread: 0
			blur: 30
			opacity: 0.4
		}

		// margin line
		Rectangle { id: margin
			width: parent.width
			height: 1
			color: GlobalVariables.colours.shadow
			// opacity: 0.4
		}
	}

	Component.onCompleted: {
		for (var item of leftItems) { item.parent = left; item.anchors.verticalCenter = left.verticalCenter; }
		for (var item of centreItems) { item.parent = centre; item.anchors.verticalCenter = centre.verticalCenter; }
		for (var item of rightItems) { item.parent = right; item.anchors.verticalCenter = right.verticalCenter; }
	}
}
