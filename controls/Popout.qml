/*-------------------------------------
--- Popout.qml - controls by andrel ---
-------------------------------------*/

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../"
import "../services"
import "../styles"

Item { id: root
	required property Item anchor
	required property Item body

	readonly property real windowWidth: window.width

	property Item header: null

	property bool isOpen: false
	property bool debug

	function open() {
		Popout.whosOpen = anchor;
		Popout.open();
		isOpen = true;
		frame.visible = true;
		anim.restart();
	}
	function close() {
		Popout.whosOpen = null;
		isOpen = false;
		anim.restart();
	}
	function toggle() {
		switch (isOpen) {
			case true:
				root.close();
				break;
			case false:
				root.open();
				break;
		}
	}

	// anchor 'frame' popup window to 'root'
	anchors.centerIn: anchor
	width: GlobalVariables.controls.barHeight
	height: width

	Connections {
		target: Popout
		function onOpen() { if (Popout.whosOpen !== anchor && root.isOpen){
			root.isOpen = false;
			anim.restart();
		}}
	}

	// for dubugging only
	Rectangle {
		visible: debug
		anchors.fill: parent
		color: "#8000ff00"
	}

	PopupWindow { id: frame
		visible: false
		mask: Region {
			x: window.x
			y: window.y
			width: window.width
			height: window.height
		}
		anchor {
			item: root;
			rect{ x: root.width /2 -width /2; y: root.height; }	// prefer window center horizontally to anchor and bellow bar
		}
		implicitWidth: window.width +60
		implicitHeight: window.height +60
		color: debug? "#80ff0000" : "transparent"

		RectangularShadow { id: windowShadow
			anchors.horizontalCenter: window.horizontalCenter
			width: window.width
			height: window.height +windowTranslate.y
			spread: 0
			blur: 30
		}

		// wrapper for all contents in popout
		Rectangle { id: window
			x: frame.width /2 -width /2
			width: Math.max((header? header.width : 0), body.width, GlobalVariables.controls.radius *2)
			height: (header? header.height : 0) +body.height
			color: debug? "#800000ff" : GlobalVariables.colours.dark
			transform: Translate { id: windowTranslate }
			layer.enabled: true
			layer.effect: OpacityMask {
				maskSource: Rectangle {
					width: window.width
					height: window.height
					radius: GlobalVariables.controls.radius
				}
			}

			// wrapper for body
			Rectangle { id: contentBody
				anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; }
				width: window.width
				height: body.height
				color: debug? "#80ff0000" : "transparent"
			}

			// draw shadow bellow header
			RectangularShadow {
				visible: header
				anchors.fill: contentHeader
				radius: contentHeader.radius
				spread: 0
				blur: 30
			}

			// wrapper for header
			Rectangle { id: contentHeader
				visible: header
				anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; }
				width: window.width
				height: Math.max(header? header.height : 0, GlobalVariables.controls.radius *2)
				radius: GlobalVariables.controls.radius
				color: debug? "#8000ff00" : GlobalVariables.colours.window

				Borders {}
			}
		}
	}

	SequentialAnimation { id: anim
		property real time: 0.25

		ParallelAnimation {
			NumberAnimation {
				target: windowTranslate
				property: "y"
				from: isOpen? -window.height : GlobalVariables.controls.spacing
				to: isOpen? GlobalVariables.controls.spacing : -window.height
				duration: anim.time *1000
				easing.type: Easing.OutCirc
			}

			NumberAnimation {
				target: windowShadow
				property: "opacity"
				from: isOpen? 0.0 : 0.4
				to: isOpen? 0.4 : 0.0
				duration: anim.time *1000
				easing.type: Easing.OutCirc
			}

			NumberAnimation {
				target: window
				property: "opacity"
				from: isOpen? 0.0 : 0.975
				to: isOpen? 0.975 : 0.0
				duration: anim.time *1000
				easing.type: Easing.OutCirc
			}
		}

		ScriptAction { script: if (!isOpen) frame.visible = false; }
	}

	Component.onCompleted: {
		body.parent = contentBody;
		if (header) header.parent = contentHeader;
	}
}

