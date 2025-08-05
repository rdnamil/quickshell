import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell

Item { id: root
	required property Item content

	readonly property bool containsMouse: mouseArea.containsMouse

	signal clicked()

	implicitWidth: content.width +10
	implicitHeight: content.height +10

	Item { id: contentWrapper
		anchors.centerIn: parent

		width: content.width
		height: content.height
	}

	Rectangle {
		visible: mouseArea.containsMouse
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
		onClicked: root.clicked()
	}

	Component.onCompleted: content.parent = contentWrapper
}
