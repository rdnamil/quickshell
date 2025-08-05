import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "root:"
import "osd"

Item { id: root
	required property Item content

	property real yPosition: 11 /24
	property bool shouldShowOsd: false

	width: content.width +50
	height: content.height +50

	Connections {
		target: Tracker
		onIsShown: {
			if(content !== root.content) {
				shouldShowOsd = false
			}
		}
	}

	Timer { id: hideTimer
		interval: 1000
		onTriggered: root.shouldShowOsd = false
	}

	LazyLoader {
		active: shouldShowOsd

		PanelWindow {
			WlrLayershell.layer: WlrLayer.Overlay
			anchors{ left: true; bottom: true; }
			margins{ left: (screen.width /2) -(root.width /2); bottom: (screen.height *yPosition) -(root.height /2); }
			implicitWidth: root.width
			implicitHeight: root.height
			color: "transparent"
			mask: Region {}

			RectangularShadow {
				anchors.fill: background
				spread: 0
				blur: 30
				color: "#70000000"
			}

			Rectangle { id: background
				anchors.centerIn: parent
				width: parent.width -50
				height: parent.height -50
				radius: height /2
				color: GlobalConfig.colour.background
				border { color: "#00000000"; width: 1; }
				clip: true
			}

			Component.onCompleted: {
				content.parent = background;
				content.anchors.centerIn = background;
			}
		}
	}

	function showOsd() {
		Tracker.isShown(content);
		shouldShowOsd = true;
		hideTimer.restart();
	}
}
