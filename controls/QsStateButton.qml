/*---------------------------------
--- QsStateButton.qml by andrel ---
---------------------------------*/

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import qs

QsButton {
	required property var checkState // values can be 'Unchecked', 'PartiallyChecked', or 'Checked'

	property var type: QsMenuButtonType.RadioButton // values can be 'CheckBox', 'RadioButton', or 'None'

	shade: false
	content: Item {
		width: button.width
		height: width

		RectangularShadow {
			anchors.fill: button
			radius: button.radius
			spread: 1
			blur: 3
			color: GlobalVariables.colours.shadow
			opacity: 0.4
		}

		Rectangle { id: button
			anchors.bottom: parent.bottom

			// button background
			width: GlobalVariables.controls.iconSize
			height: width
			radius: {
				switch (type) {
					case QsMenuButtonType.CheckBox:
						return 3;
					case QsMenuButtonType.RadioButton:
						return height /2;
					default:
						return height /2;
				}
			}
			color: checkState !== Qt.Checked? GlobalVariables.colours.midlight : GlobalVariables.colours.accent
			layer.enabled: true
			layer.effect: DropShadow {
				color: GlobalVariables.colours.light
				spread: 0
				radius: 0
				samples: 1
				verticalOffset: -1
			}
		}

		// checkmark
		Item {
			readonly property color color: GlobalVariables.colours.text

			visible: (checkState === Qt.Checked) && (type === QsMenuButtonType.CheckBox)
			anchors {
				horizontalCenter: parent.horizontalCenter
				top: parent.top
				topMargin: height *0.1
			}
			width: height *0.55
			height: parent.height *0.7
			rotation: 45

			Rectangle {
				anchors.right: parent.right
				width: parent.height *0.25
				height: parent.height
				color: parent.color
			}

			Rectangle {
				anchors.bottom: parent.bottom
				width: parent.width
				height: parent.height *0.25
				color: parent.color
			}
		}

		// radio circle
		Rectangle {
			visible: (checkState === Qt.Checked) && (type === QsMenuButtonType.RadioButton)
			anchors.centerIn: parent
			width: parent.width *0.5
			height: width
			radius: height /2
			color: GlobalVariables.colours.text
		}
	}
}
