import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import "root:"
import "popout"

Item { id: root
	required property Item anchor
	required property Item content

	property bool debug: false
	property bool isMenuOpen: false

	property string backgroundColour: GlobalConfig.colour.background
	property int margins: GlobalConfig.spacing
	property int cornerRadius: GlobalConfig.cornerRadius

	anchors.fill: anchor

	Connections {
		target: Tracker
		function onIsOpened() {
			if(menu !== root.content)
				root.close()
		}
	}

	Rectangle {
		anchors.fill: parent
		color: "#8000ff00"
		visible: debug
	}

	PopupWindow { id: window
		anchor {
			item: root
			rect{ x: root.width /2 -width /2; y: GlobalConfig.barHeight -(GlobalConfig.barHeight -root.height) /2; }
		}
		implicitWidth: content.width +50
		implicitHeight: content.height +50
		color: debug? "#80ff0000" : "transparent"
		visible: false
		mask: Region { item: menu; }

		RectangularShadow {
			anchors.fill: menu
			offset: (0,0)
			spread: 0
			blur: 30
			color: "#70000000"
		}

		Rectangle { id: menu
			x: window.width /2 -width /2
			y: margins
			width: content.width
			height: content.height
			color: debug? "#800000ff" : backgroundColour
			radius: cornerRadius
			clip: true
			layer.enabled: true
			layer.effect: OpacityMask {
				maskSource: Rectangle {
					width: menu.width
					height: menu.height
					radius: menu.radius
				}
			}

			PropertyAnimation { id: menuOpen
				target: menu
				property: "height"
				from: cornerRadius *2
				to: content.height
				duration: (content.height /100) *500
				easing.type: Easing.OutCirc
			}
		}
	}

	function open() {
		Tracker.isOpened(root.content);
		isMenuOpen = true;
		window.visible = true;
		menuOpen.start();
	}
	function openChild() {
		isMenuOpen = true;
		window.visible = true;
		menuOpen.start();
	}
	function close() {
		isMenuOpen = false;
		window.visible = false;
	}
	function closeAll() {
		Tracker.isOpened(null);
	}
	function toggle() {
		if (isMenuOpen) {
			root.close();
		} else {
			root.open();
		}
	}

	Component.onCompleted: {
		content.parent = menu;
		content.anchors.bottom = menu.bottom;
		closeAll();
	}
}
