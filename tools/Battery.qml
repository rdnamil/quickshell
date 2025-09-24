import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import "root:"

Item { id: root
	property real percentage: 1.0
	property bool isCharging
	property bool material

	width: 12
	height: 24

	RectangularShadow {
		visible: !root.material
		anchors.fill: healthBar
		offset { x: 0; y: 0; }
		radius: healthBar.radius
		spread: 2
		blur: 2
		color: Qt.darker (healthBar.color, 1.25)
	}

	Rectangle { id: healthBar
		anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 2; }
		width: parent.width -4
		height: (parent.height -5) *percentage
		radius: 1
		color: {
			let health = null
			if (percentage <= 0.15) {
				health = GlobalConfig.colour.red
			} else if (percentage <= 0.33) {
				health = GlobalConfig.colour.orange
			} else {
				health = GlobalConfig.colour.green
			}
			return health;
		}
	}

	Item { id: light
		visible: isCharging
		anchors.centerIn: overlay
		width: overlay.width
		height: width
		layer.enabled: true
		layer.effect: OpacityMask {
			invert: true
			maskSource: Item {
				width: light.width
				height: light.height

				Rectangle {
					anchors.bottom: parent.bottom
					width: light.width
					height: ((overlay.height *percentage)) -((overlay.height /2) -(light.height /2))
				}
			}
		}

		Text {
			anchors.centerIn: parent
			text: "󱐋"
			color: GlobalConfig.colour.foreground
			font.pixelSize: parent.width
			rotation: -root.rotation
		}
	}

	Item { id: dark
		visible: isCharging
		anchors.centerIn: overlay
		width: overlay.width
		height: width
		layer.enabled: true
		layer.effect: OpacityMask {
			maskSource: Item {
				width: dark.width
				height: dark.height

				Rectangle {
					anchors.bottom: parent.bottom
					width: dark.width
					height: (overlay.height *percentage) -((overlay.height /2) -(dark.height /2))
				}
			}
		}

		Text {
			anchors.centerIn: parent
			text: "󱐋"
			color: GlobalConfig.colour.background
			font.pixelSize: parent.width
			rotation: -root.rotation
		}
	}

	Rectangle { id: overlay
		anchors.bottom: parent.bottom
		width: parent.width
		height: parent.height -1
		radius: 3
		color: "transparent"
		border { width: 1; color: GlobalConfig.colour.foreground; }
		gradient: { if (!material) return sku;}

		Gradient { id: sku
			orientation: Gradient.Horizontal
			GradientStop { position: 0.0; color: "#20000000" }
			GradientStop { position: 0.1; color: "#80ffffff" }
			GradientStop { position: 0.5; color: "#00000000" }
			GradientStop { position: 1.0; color: "#40000000" }
		}


	}

	Rectangle {
		anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; }
		width: 4
		height: 1
		color: GlobalConfig.colour.foreground
	}
}
