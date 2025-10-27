/*-------------------
--- AppDrawer.qml ---
-------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "../"
import "../controls"

QsButton { id: root
	// readonly property list<string> categories: {
	// 	var categories = [];
	//
	// 	for (const cats of DesktopEntries.applications.values.map(a => a.categories)) {
	// 		for (const cat of cats) if (!categories.includes(cat)) categories.push(cat);
	// 	}
	//
	// 	return categories;
	// }

	// readonly property list<string> categories: [
	// 	"Favourites",
	// 	"Utility",
	// 	"Settings",
	// 	"Internet",
	// 	"Game",
	// 	"Security",
	// 	"Office",
	// 	"Development"
	// ]

	property list<string> favourites: [
		"Ghostty",
		"Thunar File Manager",
		"Brave",
		"Legcord",
		"Steam",
		"Lutris"
	]

	anim: false
	shade: false
	onClicked: popout.toggle();
	content: IconImage {
		implicitSize: GlobalVariables.controls.iconSize
		source: Quickshell.iconPath("view-app-grid")
	}

	Popout { id: popout
		property string usersname

		anchor: root
		body: ColumnLayout {
			// user/power options
			RowLayout {
				Layout.minimumWidth: 256

				Text {
					Layout.alignment: Qt.AlignVCenter
					Layout.leftMargin: GlobalVariables.controls.padding
					text: popout.usersname
					verticalAlignment: Text.AlignVCenter
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.regular
				}

				Row {
					Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
					Layout.rightMargin: GlobalVariables.controls.padding
					spacing: 4

					QsButton {
						onClicked: Quickshell.execDetached(["sh", "-c", "/home/$USER/.local/bin/lockscreen.sh"])
						content: IconImage {
							implicitSize: GlobalVariables.controls.iconSize
							source: Quickshell.iconPath("system-lock-screen")
						}
					}
					QsButton {
						onClicked: Quickshell.execDetached(["logout"])
						content: IconImage {
							implicitSize: 16
							source: Quickshell.iconPath("system-log-out")
						}
					}
					QsButton {
						onClicked: Quickshell.execDetached(["reboot"])
						content: IconImage {
							implicitSize: GlobalVariables.controls.iconSize
							source: Quickshell.iconPath("system-restart")
						}
					}
					QsButton {
						onClicked: Quickshell.execDetached(["poweroff"])
						content: IconImage {
							implicitSize: GlobalVariables.controls.iconSize
							source: Quickshell.iconPath("system-shutdown")
						}
					}
				}
			}
		}

		Process {
			running: true
			command: ["sh", "-c", 'getent passwd "$USER" | cut -d: -f5 | cut -d, -f1']
			stdout: StdioCollector {
				onStreamFinished: popout.usersname = text;
			}
		}
	}
}
