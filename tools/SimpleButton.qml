import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import "root:"

Item { id: root
	required property Item content

	readonly property bool containsMouse: mouseArea.containsMouse

	property bool darken: true
	property bool animate: true
	property bool drawBackground: false

	signal clicked()
	signal pressed()
	signal animMean()
	signal animCompleted()
	signal mouseEntered()
	signal mouseExited()

	onContainsMouseChanged: {
		containsMouse? root.mouseEntered() : root.mouseExited();
	}

	width: contentWrapper.width
	height: contentWrapper.height

	Rectangle {
		visible: mouseArea.containsMouse && drawBackground
		anchors.centerIn: parent
		width: parent.width -GlobalConfig.padding
		height: parent.height
		radius: 3
		color: GlobalConfig.colour.surface
		// opacity: 0.5
		transform: Translate { id: backgroundTranslate; y: contentTranslate.y; }
	}

	Item { id: contentWrapper
		width: content.width +4
		height: content.height +4
	}

	Rectangle {
		visible: mouseArea.containsMouse && darken
		anchors.fill: contentWrapper
		color: "#20000000"
		layer.enabled: true
		layer.effect: OpacityMask {
			maskSource: contentWrapper
		}
	}

	MouseArea { id: mouseArea
		anchors.fill: root
		hoverEnabled: true
		onPressed: { if (animate) pressedAnim.start(); root.pressed(); }
		onReleased: { if (animate) releasedAnim.start(); root.clicked(); }
	}

	Translate { id: contentTranslate; y: 0; }

	PropertyAnimation { id: pressedAnim
		target: contentTranslate
		properties: "x,y"
		to: 2
		duration: 25
		easing.type: Easing.InCirc;
	}

	PropertyAnimation { id: releasedAnim
		onStarted: root.animMean();
		onFinished: root.animCompleted();
		target: contentTranslate
		properties: "x,y"
		to: 0
		duration: 25
		easing.type: Easing.InCirc;
	}

	Component.onCompleted: {
		content.parent = contentWrapper;
		content.anchors.centerIn = contentWrapper;
		content.transform = contentTranslate;
	}
}
