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

	property bool anim: true
	property bool shade: true
	property bool highlight: false
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
	Rectangle {
		anchors.centerIn: parent
		visible: highlight && containsMouse
		width: parent.width +4
		height: parent.height +4
		color: GlobalVariables.colours.accent
		opacity: 0.4
	}

	// contentWrapper
	Item { id: contentWrapper
		anchors.fill: parent
	}

	// shade button on hover
	Rectangle {
		visible: shade && containsMouse
		anchors.fill: parent
		color: GlobalVariables.colours.shadow
		opacity: 0.2
		layer.enabled: true
		layer.effect: OpacityMask {
			maskSource: content
		}
	}

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
		anchors.centerIn: root
		width: root.width +4
		height: root.height +4
		hoverEnabled: true
		onEntered: { root.mouseEntered(); if (root.tooltip) tooltipTimer.restart(); }
		onExited: {
			root.mouseExited();
			if (root.tooltip) {
				tooltipTimer.stop();
				tooltip.isShown = false;
			}
		}

		acceptedButtons: Qt.AllButtons
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
