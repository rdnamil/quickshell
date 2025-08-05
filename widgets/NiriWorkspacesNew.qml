/*--------------------------------------
--- Niri workspaces widget by andrel ---
--------------------------------------*/

import QtQuick
import Quickshell
import Quickshell.Io
import "root:"
import "niriWorkspaces"

Item { id: root
	property int workspaceSelected
	property list<string> command: ["niri", "msg", "action", "focus-workspace", workspaceSelected]	// command to run on mouse pressed
	property string style: "pills"	// options include 'named', '2tone', 'pills', and 'custom'
	property list<string> workspaceNames: ["一", "二", "三", "四", "五"]
	property bool showText: pillStyle.text
	property QtObject pillStyle: {
		switch (style) {
			case "named":
				return Styles.named
				break;
			case "pills":
				return Styles.pills
				break;
		}
	}

	implicitWidth: layout.width
	implicitHeight: layout.height

	Behavior on implicitWidth { NumberAnimation { duration: 750; easing.type: Easing.OutCirc; }}

	Process { id: runCommand
		running: false
		command: root.command
	}

	Row { id: layout
		anchors.verticalCenter: parent.verticalCenter

		Repeater {
			model: NiriWorkspaces.numWorkspaces

			Item {
				required property int index

				anchors.verticalCenter: parent.verticalCenter

				width: pill.width +6
				height: pill.height +12

				MouseArea { id: mouseArea
					anchors.fill: parent
					hoverEnabled: true
					onClicked: event => {
						workspaceSelected = index +1
						runCommand.running = true
					}
				}

				Pill { id: pill
					anchors.centerIn: parent
					isFocused: index === (NiriWorkspaces.focusedWorkspace -1)
					style: pillStyle

					Rectangle {
						visible: mouseArea.containsMouse
						anchors.fill: parent
						radius: pill.radius
						color: "#30000000"
					}

					Text {
						visible: showText
						anchors.centerIn: pill
						text: workspaceNames[index]
						font.pixelSize: pill.height -6
					}
				}
			}
		}
	}
}
