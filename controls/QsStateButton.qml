/*---------------------------------
--- QsStateButton.qml by andrel ---
---------------------------------*/

import QtQuick
import Quickshell
import "../"

QsButton {
	required property var checkState // values can be 'Unchecked', 'PartiallyChecked', or 'Checked'

	property var type: QsMenuButtonType.RadioButton // values can be 'CheckBox', 'RadioButton', or 'None'

	shade: false
	content: Rectangle {
		// button background
		width: GlobalVariables.controls.iconSize
		height: width
		radius: {
			switch (type) {
				case QsMenuButtonType.CheckBox:
					return 3;
				case QsMenuButtonType.RadioButton:
					return height /2;
			}
		}
		color: checkState !== Qt.Checked? GlobalVariables.colours.midlight : GlobalVariables.colours.accent

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
