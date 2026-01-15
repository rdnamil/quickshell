
import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import qs

Item { id: root
	property color fillColour: {
		switch (Math.round((percentage *100) /10) *10) {
			case 10:
				return "red";
			case 20:
				return "orange";
			case 30:
				return "orange";
			default:
				return "forestgreen";
		}
	}
	property real percentage
	property bool isCharging
	property bool material

	width: 24
	height: 16

	Rectangle { id: batteryContainer
		readonly property bool isPortrait: parent.height > parent.width

		anchors {
			left: parent.left
			bottom: parent.bottom
		}
		width: isPortrait? parent.width : parent.width -1
		height: isPortrait? parent.height -1 : parent.height
		radius: 3
		color: "transparent"
		border { width: 1; color: GlobalVariables.colours.text; }

		Item { id: fillContainer
			anchors.centerIn: parent
			width: parent.width -4
			height: parent.height -4
			layer.enabled: true
			layer.effect: OpacityMask {
				invert: true
				maskSource: Item {
					width: fillContainer.width
					height: fillContainer.height

					Text {
						visible: isCharging
						anchors.centerIn: parent
						text: "󱐋"
						font.pixelSize: parent.height
						style: Text.Outline
						styleColor: "transparent"
					}
				}
			}

			Rectangle { id: fill
				anchors {
					left: parent.left
					bottom: parent.bottom
				}
				visible: percentage > 0
				width: batteryContainer.isPortrait? parent.width : parent.width *percentage
				height: batteryContainer.isPortrait? parent.height *percentage : parent.height
				color: fillColour
				layer.enabled: true
				layer.effect: OpacityMask {
					maskSource: Item {
						width: fill.width
						height: fill.height

						Rectangle {
							anchors {
								left: parent.left
								bottom: parent.bottom
							}
							width: fillContainer.width
							height: fillContainer.height
							radius: 1
						}
					}
				}
			}

			Text {
				visible: isCharging
				anchors.centerIn: parent
				text: "󱐋"
				font.pixelSize: parent.height
				style: Text.Outline
				styleColor: fillColour
			}

			Rectangle { id: overlay
				anchors.fill: parent
				radius: 3
				color: "transparent"
				gradient: material? null : sku

				Gradient { id: sku
					orientation: batteryContainer.isPortrait? Gradient.Horizontal : Gradient.Vertical
					GradientStop { position: 0.0; color: "#20000000" }
					GradientStop { position: 0.1; color: "#80ffffff" }
					GradientStop { position: 0.5; color: "#00000000" }
					GradientStop { position: 1.0; color: "#40000000" }
				}
			}
		}

		Rectangle {
			anchors {
				left: parent.right
				leftMargin: batteryContainer.isPortrait? -parent.width /2 -width /2 : 0
				bottom: parent.top
				bottomMargin: batteryContainer.isPortrait? 0 : -parent.height /2 -height /2
			}
			width: batteryContainer.isPortrait? parent.width /3 : 1
			height: batteryContainer.isPortrait? 1 : parent.height /3
			color: GlobalVariables.colours.text
		}
	}
}
