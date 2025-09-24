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
			adjustment: PopupAdjustment.Slide
		}
		width: content.width +60
		height: content.height +60
		color: debug? "#80ff0000" : "transparent"
		visible: false
		mask: Region { item: menu; }

		RectangularShadow { id: shadow
			anchors.fill: menu
			offset.y: 10
			radius: menu.radius
			spread: 0
			blur: 30
			color: "black"
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
					color: "#faaaaaaa"
				}
			}
		}
	}

	SequentialAnimation { id: menuAnim
		ParallelAnimation {
			NumberAnimation {
				target: menu
				property: "height"
				from: isMenuOpen? cornerRadius *2 : content.height
				to: isMenuOpen? content.height : cornerRadius *2
				duration: 200
				easing.type: Easing.OutCirc
			}
			NumberAnimation {
				target: menu
				property: "opacity"
				from: isMenuOpen? 0.0 : 1.0
				to: isMenuOpen? 1.0 : 0.0
				duration: 200
				easing.type: Easing.OutCirc
			}
			NumberAnimation {
				target: shadow
				property: "opacity"
				from: isMenuOpen? 0.0 : 0.4
				to: isMenuOpen? 0.4 : 0.0
				duration: 200
				easing.type: Easing.OutCirc
			}
		}

		ScriptAction { script: { if (!isMenuOpen) window.visible = false; }}
	}

	function open() {
		Tracker.isOpened(root.content);
		isMenuOpen = true;
		window.visible = true;
		menuAnim.restart();
	}
	function close() {
		isMenuOpen = false;
		menuAnim.restart();
		// window.visible = false;
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
		root.closeAll();
	}
}
