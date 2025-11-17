/*----------------------------
--- QsButton.qml by andrel ---
----------------------------*/

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import qs

Item { id: root
	required property Item content

	readonly property bool containsMouse: mouseArea.containsMouse
	readonly property real mouseX: mouseArea.mouseX
	readonly property real mouseY: mouseArea.mouseY

	property bool anim: true
	property bool shade: true
	property bool highlight
	property bool fill
	property bool isHighlighted: (root.highlight && containsMouse)
	property Item tooltip
	property bool debug

	signal pressed()
	signal clicked()
	signal middleClicked()
	signal mouseEntered()
	signal mouseExited()
	signal animMean()

	width: content.width
	height: content.height
	transform: Translate { id: rootTranslate; }

	// highlight button on hover
	Rectangle { id: highlight
		anchors.centerIn: parent
		visible: isHighlighted || fill
		width: parent.width +4
		height: parent.height +4
		color: GlobalVariables.colours.accent
		opacity: containsMouse? 0.5 : 0.25
	}

	// contentWrapper
	Item { id: contentWrapper
		anchors.fill: parent
		layer.enabled: true
		layer.effect: ColorOverlay {
			function setAlpha(colour, alpha) {
				return Qt.rgba(colour.r, colour.g, colour.b, alpha);
			}
			color: {
				if (shade && containsMouse) return setAlpha(GlobalVariables.colours.shadow, 0.2);
				else return "transparent";
			}
		}
	}

	// shade button on hover
	// Rectangle {
	// 	visible: shade && containsMouse
	// 	width: content.width
	// 	height: content.height
	// 	x: content.x
	// 	y: content.y
	// 	color: GlobalVariables.colours.shadow
	// 	opacity: 0.2
	// 	layer.enabled: true
	// 	layer.effect: OpacityMask {
	// 		maskSource: content
	// 	}
	// }

	QsTooltip { id: tooltip
		anchor: root
		content: root.tooltip

		Timer { id: tooltipTimer
			running: false
			interval: 1500
			onTriggered: parent.isShown = true;
		}
	}

	MouseArea { id: mouseArea
		width: content.width +4
		height: content.height +4
		x: content.x -2
		y: content.y -2
		hoverEnabled: true
		onEntered: { root.mouseEntered(); if (root.tooltip) tooltipTimer.restart(); }
		onExited: {
			root.mouseExited();
			if (root.tooltip) {
				tooltipTimer.stop();
				tooltip.isShown = false;
			}
		}
		acceptedButtons: Qt.LeftButton | Qt.MiddleButton
		onPressed: (mouse) => {
			switch (mouse.button) {
				case Qt.LeftButton: {
					if (root.anim) {
						pressedAnim.start();
					} else root.clicked();

					root.pressed();
					break;
				}
				case Qt.MiddleButton:
					root.middleClicked();
					break;
			}
		}
		onReleased: if (anim) releasedAnim.start();

		Rectangle {
			visible: debug
			anchors.fill: parent
			color: "#4000ff00"
		}
	}

	PropertyAnimation { id: pressedAnim
		target: rootTranslate
		properties: "y"
		to: 2
		duration: 25
		easing.type: Easing.InCirc;
	}

	PropertyAnimation { id: releasedAnim
		target: rootTranslate
		properties: "y"
		to: 0
		duration: 25
		easing.type: Easing.InCirc;
		onStarted: root.animMean();
		onFinished: root.clicked();
	}

	Component.onCompleted: {
		content.parent = contentWrapper;
	}
}
