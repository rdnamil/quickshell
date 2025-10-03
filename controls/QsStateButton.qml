/*---------------------------------
--- QsStateButton.qml by andrel ---
---------------------------------*/

import QtQuick
import Quickshell
import "../"

Rectangle {
	property var type: QsMenuButtonType.CheckBox // values can be 'CheckBox', 'RadioButton', or 'None'
	property var checkState: Qt.Checked // values can be 'Unchecked', 'PartiallyChecked', or 'Checked'

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
	color: isChecked? GlobalVariables.colours.accent : GlobalVariables.colours.midlight

	// checkmark
	Item {
		readonly property color color: GlobalVariables.colours.text

		visible: isChecked && (type === QsMenuButtonType.CheckBox)
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
		visible: isChecked && (type === QsMenuButtonType.RadioButton)
		anchors.centerIn: parent
		width: parent.width *0.5
		height: width
		radius: height /2
		color: GlobalVariables.colours.text
	}
}
