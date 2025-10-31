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
				spacing: GlobalVariables.controls.spacing

				Text {
					// visible: false
					Layout.alignment: Qt.AlignVCenter
					Layout.leftMargin: GlobalVariables.controls.padding
					Layout.rightMargin: GlobalVariables.controls.padding
					text: popout.usersname
					verticalAlignment: Text.AlignVCenter
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.regular
				}

				Row {
					Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
					Layout.rightMargin: GlobalVariables.controls.padding
					spacing: GlobalVariables.controls.spacing

					Row {
						spacing: 3

						Repeater {
							model: DesktopEntries.applications.values.filter(a => favourites.includes(a.name)).sort((a, b) => {
								return favourites.indexOf(a.name) -favourites.indexOf(b.name);
							})
							delegate: QsButton {
								required property var modelData

								onClicked: {
									modelData.execute();
									popout.toggle();
								}
								content: IconImage {
									implicitSize: GlobalVariables.controls.iconSize
									source: Quickshell.iconPath(modelData.id.toLowerCase(), true) || Quickshell.iconPath(modelData.icon)
								}
							}
						}
					}

					Rectangle {
						anchors.verticalCenter: parent.verticalCenter
						width: 6
						height: width
						radius: height /2
						color: GlobalVariables.colours.text
					}

					Row {
						spacing: 3

						QsButton {
							onClicked: {
								Quickshell.execDetached(["sh", "-c", "/usr/local/bin/lockscreen.sh"]);
								popout.toggle();
							}
							content: IconImage {
								implicitSize: GlobalVariables.controls.iconSize
								source: Quickshell.iconPath("system-lock-screen")
							}
						}
						QsButton {
							onClicked: {
								Quickshell.execDetached(["logout"]);
								popout.toggle();
							}
							content: IconImage {
								implicitSize: 16
								source: Quickshell.iconPath("system-log-out")
							}
						}
						QsButton {
							onClicked: {
								Quickshell.execDetached(["poweroff"]);
								popout.toggle();
							}
							content: IconImage {
								implicitSize: GlobalVariables.controls.iconSize
								source: Quickshell.iconPath("system-shutdown")
							}
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
