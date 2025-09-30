/*----------------------------
--- QsButton.qml by andrel ---
----------------------------*/

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import "../"

Item { id: root
	required property Item content

	readonly property bool containsMouse: mouseArea.containsMouse

	property bool anim: true
	property bool shade: true
	property bool highlight: false

	signal pressed()
	signal clicked()
	signal mouseEntered()
	signal mouseExited()
	signal animMean()

	width: content.width
	height: content.height
	transform: Translate { id: rootTranslate; }

	Rectangle {
		anchors.centerIn: parent
		visible: highlight && containsMouse
		width: parent.width +4
		height: parent.height +4
		color: GlobalVariables.colours.accent
		opacity: 0.4
	}

	Item { id: contentWrapper
		anchors.fill: parent
	}

	Rectangle { id: shader
		visible: shade && containsMouse
		anchors.fill: parent
		color: GlobalVariables.colours.shadow
		opacity: 0.2
		layer.enabled: true
		layer.effect: OpacityMask {
			maskSource: content
		}
	}

	MouseArea { id: mouseArea
		anchors.centerIn: root
		width: root.width +4
		height: root.height +4
		hoverEnabled: true
		onPressed: {
			if (anim) {
				pressedAnim.start();
			} else root.clicked();
			root.pressed();
		}
		onReleased: if (anim) releasedAnim.start();
		onClicked: (mouse) => { if (mouse.button === Qt.MiddleButton) root.middleClicked(); }
		onEntered: root.mouseEntered();
		onExited: root.mouseExited();
	}

	PropertyAnimation { id: pressedAnim
		target: rootTranslate
		properties: "x,y"
		to: 2
		duration: 25
		easing.type: Easing.InCirc;
	}

	PropertyAnimation { id: releasedAnim
		target: rootTranslate
		properties: "x,y"
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
