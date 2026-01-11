/*---------------------------
--- Marquee.qml by andrel ---
---------------------------*/

import QtQuick
import qs

Item { id: root
	required property Item content

	// set property to content width to monitor for changes
	readonly property real contentWidth: content.width

	property int spacing: 8
	property int speed: 50
	property bool scroll: content.width > root.width
	property bool leftAlign

	function restart() {
		// stop the scrolling animation and update values
		animA.stop();
		animA.to = -(content.width +spacing *2);
		animA.duration = (content.width /speed) *1000;
		// restart animation and reset back to starting position
		animA.start();
		animA.complete();
		// set animation running to set behavior
		animA.running = scroll;

		// animB
		animB.stop();
		animB.from = (content.width +spacing *2);
		animB.duration = (content.width /speed) *1000;
		animB.start();
		animB.complete();
		animB.running = scroll;
	}

	onScrollChanged: restart();
	onContentWidthChanged: root.restart();
	width: content.width
	height: content.height
	clip: true

	ShaderEffectSource {
		anchors.verticalCenter: parent.verticalCenter
		// centre in parent when not scrolling
		x: !animA.running && !leftAlign? root.width /2 - width /2 : 0
		width: content.width
		height: content.height
		sourceItem: content
		transform: Translate {
			NumberAnimation on x { id: animA
				running: scroll
				from: 0
				to: -(content.width +spacing *2)
				duration: (content.width /speed) *1000
				loops: Animation.Infinite
			}
		}

		// seperator dot
		Rectangle {
			visible: animA.running	// hide when not scrolling
			anchors.verticalCenter: parent.verticalCenter
			x: content.width +spacing -width /2
			width: 3
			height: width
			radius: height /2
			color: GlobalVariables.colours.text
		}
	}

	ShaderEffectSource {
		visible: animB.running	// hide when not scrolling
		anchors.verticalCenter: parent.verticalCenter
		width: content.width
		height: content.height
		sourceItem: content
		transform: Translate {
			NumberAnimation on x { id: animB
				running: scroll
				from: (content.width +spacing *2)
				to: 0
				duration: (content.width /speed) *1000
				loops: Animation.Infinite
			}
		}
	}
}
