/*-------------------------
--- Power.qml by andrel ---
-------------------------*/

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs
import qs.controls as Ctrl
import qs.styles as Style

Ctrl.QsButton { id: root
	anim: false
	shade: false
	onClicked: popout.toggle();
	content: IconImage {
		implicitSize: GlobalVariables.controls.iconSize
		// source: Quickshell.iconPath("endeavouros")
		source: Quickshell.iconPath("system-shutdown")
 	}

 	Ctrl.Popout { id: popout
		anchor: root
		body: Rectangle {
			width: options.width
			height: options.height
			radius: GlobalVariables.controls.radius
			color: "transparent"

			Style.Borders {}

			Row { id: options
				padding: GlobalVariables.controls.padding
				spacing: 3

				Ctrl.QsButton {
					onClicked: { Lockscreen.lock(); popout.close(); }
					tooltip: Text {
						text: "Log out"
						color: GlobalVariables.colours.text
						font: GlobalVariables.font.regular
					}
					content: Style.Button {
						IconImage {
							anchors.centerIn: parent
							implicitSize: GlobalVariables.controls.iconSize
							source: Quickshell.iconPath("system-lock-screen")
						}
					}
				}

				Ctrl.QsButton {
					onClicked: Quickshell.execDetached(['niri', 'msg', 'action', 'quit', '-s'])
					tooltip: Text {
						text: "Log out"
						color: GlobalVariables.colours.text
						font: GlobalVariables.font.regular
					}
					content: Style.Button {
						IconImage {
							anchors.centerIn: parent
							implicitSize: GlobalVariables.controls.iconSize
							source: Quickshell.iconPath("system-log-out")
						}
					}
				}

				Ctrl.QsButton {
					onClicked: Quickshell.execDetached(['systemctl', 'suspend'])
					tooltip: Text {
						text: "Suspend"
						color: GlobalVariables.colours.text
						font: GlobalVariables.font.regular
					}
					content: Style.Button {
						IconImage {
							anchors.centerIn: parent
							implicitSize: GlobalVariables.controls.iconSize
							source: Quickshell.iconPath("system-suspend")
						}
					}
				}

				Ctrl.QsButton {
					onClicked: Quickshell.execDetached(['reboot'])
					tooltip: Text {
						text: "Restart"
						color: GlobalVariables.colours.text
						font: GlobalVariables.font.regular
					}
					content: Style.Button {
						IconImage {
							anchors.centerIn: parent
							implicitSize: GlobalVariables.controls.iconSize
							source: Quickshell.iconPath("system-reboot")
						}
					}
				}

				Ctrl.QsButton {
					onClicked: Quickshell.execDetached(['poweroff'])
					tooltip: Text {
						text: "Shut down"
						color: GlobalVariables.colours.text
						font: GlobalVariables.font.regular
					}
					content: Style.Button {
						IconImage {
							anchors.centerIn: parent
							implicitSize: GlobalVariables.controls.iconSize
							source: Quickshell.iconPath("system-shutdown")
						}
					}
				}
			}
		}
	}
}
