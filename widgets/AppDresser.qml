/*------------------------------
--- AppDresser.qml by andrel ---
------------------------------*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "../"
import "../controls"
import "../styles" as Style

QsButton { id: root
	readonly property list<var> categories: [
		{ text: "Utility", icon: "applications-utilities-symbolic" },
		{ text: "Settings", icon: "applications-system-symbolic" },
		{ text: "Internet", icon: "applications-webbrowsers-symbolic" },
		{ text: "Multimedia", icon: "applications-multimedia-symbolic" },
		{ text: "Game", icon: "game-app-symbolic" },
		{ text: "Security", icon: "security-medium-symbolic" },
		{ text: "Office", icon: "applications-office-symbolic" },
		{ text: "Development", icon: "applications-development-symbolic" },
	]

	property list<string> favourites: [
		"Ghostty",
		"Thunar File Manager",
		"Brave",
		"Mission Center",
		"Legcord",
		"Steam",
		"Lutris",
		"OBS Studio",
		"Timeshift",
		"Kate",
		"Krita",
		"Inkscape"
	]
	property string drawer: "Favourites"

	function reset() {
		root.drawer = "Favourites";
		categoryScrollView.ScrollBar.vertical.position = 0.0;
		appScrollView.ScrollBar.vertical.position = 0.0;
		appRepeater.model = appRepeater.model = DesktopEntries.applications.values.filter(a => favourites.includes(a.name)).sort((a, b) => {
			return favourites.indexOf(a.name) -favourites.indexOf(b.name);
		});
	}

	shade: false
	anim: false
	onClicked: popout.toggle();
	content: IconImage {
		implicitSize: GlobalVariables.controls.iconSize
		source: Quickshell.iconPath("view-app-grid")
	}

	Popout { id: popout
		onIsOpenChanged: if (!isOpen) root.reset();
		anchor: root
		header: RowLayout { id: headerContent
			width: Math.max(320, bodyContent.width)

			Row {
				Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
				Layout.leftMargin: GlobalVariables.controls.padding
				spacing: 6

				// get user's full name
				Process {
					running: true
					command: ["sh", "-c", 'getent passwd "$USER" | cut -d: -f5 | cut -d, -f1']
					stdout: StdioCollector {
						onStreamFinished: usersname.text = text;
					}
				}

				Rectangle {
					width: 20
					height: width
					radius: height /2
					color: GlobalVariables.colours.light
					layer.enabled: true
					layer.effect: OpacityMask {
						maskSource: Rectangle {
							width: 20
							height: width
							radius: height /2
						}
					}

					IconImage {
						anchors{
							horizontalCenter: parent.horizontalCenter
							bottom: parent.bottom
							bottomMargin: -2
						}
						implicitSize: 18
						source: Quickshell.iconPath("user-icon")
					}
				}

				Text { id: usersname
					anchors.verticalCenter: parent.verticalCenter
					color: GlobalVariables.colours.text
					verticalAlignment: Text.AlignVCenter
					font: GlobalVariables.font.regular
				}
			}

			Row {
				Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
				Layout.margins: GlobalVariables.controls.padding
				spacing: 3

				QsButton {
					onClicked: {
						Quickshell.execDetached(["sh", "-c", "/usr/local/bin/lockscreen.sh"]);
						popout.toggle();
					}
					content: Style.Button {
						IconImage {
							anchors.centerIn: parent
							implicitSize: GlobalVariables.controls.iconSize
							source: Quickshell.iconPath("system-lock-screen")
						}
					}
				}
				QsButton {
					onClicked: {
						Quickshell.execDetached(["logout"]);
						popout.toggle();
					}
					content: Style.Button {
						IconImage {
							anchors.centerIn: parent
							implicitSize: GlobalVariables.controls.iconSize
							source: Quickshell.iconPath("system-log-out")
						}
					}
				}
				QsButton {
					onClicked: {
						Quickshell.execDetached(["poweroff"]);
						popout.toggle();
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
		body: RowLayout { id: bodyContent
			spacing: 0

			ScrollView { id: categoryScrollView
				Layout.alignment: Qt.AlignLeft | Qt.AlignTop
				Layout.preferredWidth: categoryList.width +effectiveScrollBarWidth
				Layout.preferredHeight: screen.height /3
				Layout.maximumHeight: screen.height /3
				topPadding: GlobalVariables.controls.padding
				bottomPadding: GlobalVariables.controls.padding
				background: Rectangle {
					anchors.fill: parent
					color: GlobalVariables.colours.midlight
				}

				// list category drawer options
				ColumnLayout { id: categoryList
					spacing: GlobalVariables.controls.spacing

					// top padding element
					Item { Layout.preferredHeight: 1; }

					// all apps drawer option
					QsButton {
						Layout.fillWidth: true
						shade: false
						highlight: true
						onClicked: {
							root.drawer = "All Applications";
							appRepeater.model = Array.from(DesktopEntries.applications.values).sort((a, b) => a.name.localeCompare(b.name));
						}
						content: Row {
							leftPadding: GlobalVariables.controls.padding
							rightPadding: GlobalVariables.controls.padding
							spacing: GlobalVariables.controls.spacing

							IconImage {
								implicitSize: 20
								source: Quickshell.iconPath("appgrid-symbolic")
							}

							Text {
								anchors.verticalCenter: parent.verticalCenter
								text: "All Applications"
								verticalAlignment: Text.AlignVCenter
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.regular
							}
						}

						Rectangle {
							visible: drawer === "All Applications"
							anchors {
								right: parent.right
								verticalCenter: parent.verticalCenter
							}
							width: 3
							height: parent.height +4
							color: GlobalVariables.colours.accent
						}
					}

					// favourites drawer option
					QsButton {
						Layout.fillWidth: true
						shade: false
						highlight: true
						onClicked: {
							root.drawer = "Favourites";
							appRepeater.model = DesktopEntries.applications.values.filter(a => favourites.includes(a.name)).sort((a, b) => {
								return favourites.indexOf(a.name) -favourites.indexOf(b.name);
							});
						}
						content: Row {
							leftPadding: GlobalVariables.controls.padding
							rightPadding: GlobalVariables.controls.padding
							spacing: GlobalVariables.controls.spacing

							IconImage {
								implicitSize: 20
								source: Quickshell.iconPath("bookmarks-symbolic")
							}

							Text {
								anchors.verticalCenter: parent.verticalCenter
								text: "Favourites"
								verticalAlignment: Text.AlignVCenter
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.regular
							}
						}

						Rectangle {
							visible: drawer === "Favourites"
							anchors {
								right: parent.right
								verticalCenter: parent.verticalCenter
							}
							width: 3
							height: parent.height +4
							color: GlobalVariables.colours.accent
						}
					}

					Repeater {
						model: categories
						delegate: QsButton {
							required property var modelData

							Layout.fillWidth: true
							shade: false
							highlight: true
							onClicked: {
								root.drawer = modelData.text;
								appRepeater.model = Array.from(DesktopEntries.applications.values.filter(a => a.categories.includes(modelData.text))).sort((a, b) => a.name.localeCompare(b.name));
							}
							content: Row {
								leftPadding: GlobalVariables.controls.padding
								rightPadding: GlobalVariables.controls.padding
								spacing: GlobalVariables.controls.spacing

								IconImage {
									implicitSize: 20
									source: Quickshell.iconPath(modelData.icon)
								}

								Text {
									anchors.verticalCenter: parent.verticalCenter
									text: modelData.text
									verticalAlignment: Text.AlignVCenter
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.regular
								}
							}

							Rectangle {
								visible: drawer === modelData.text
								anchors {
									right: parent.right
									verticalCenter: parent.verticalCenter
								}
								width: 3
								height: parent.height +4
								color: GlobalVariables.colours.accent
							}
						}
					}

					// bottom padding element
					Item { Layout.preferredHeight: 1; }
				}
			}

			Seperator {
				Layout.preferredHeight: parent.height
			}

			ScrollView { id: appScrollView
				Layout.alignment: Qt.AlignLeft | Qt.AlignTop
				Layout.preferredWidth: screen.width /8
				Layout.preferredHeight: screen.height /3
				Layout.maximumHeight: screen.height /3
				ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
				topPadding: GlobalVariables.controls.padding
				bottomPadding: GlobalVariables.controls.padding

				// app list
				ColumnLayout { id: appList
					width: parent.width

					// top padding element
					Item { Layout.preferredHeight: 1; }

					Repeater { id: appRepeater
						model: appRepeater.model = DesktopEntries.applications.values.filter(a => favourites.includes(a.name)).sort((a, b) => {
							return favourites.indexOf(a.name) -favourites.indexOf(b.name);
						})
						delegate: QsButton {
							required property var modelData

							Layout.fillWidth: true
							shade: false
							highlight: true
							// onMiddleClicked:
							onClicked: {
								modelData.categories.push("Favourites");
								modelData.execute();
								popout.toggle();
							}
							content: Row {
								leftPadding: GlobalVariables.controls.padding
								rightPadding: GlobalVariables.controls.padding
								spacing: GlobalVariables.controls.spacing

								IconImage {
									anchors.verticalCenter: parent.verticalCenter
									implicitSize: 32
									source: Quickshell.iconPath(modelData.id, true) || Quickshell.iconPath(modelData.icon, "image-missing")
								}

								Column {
									anchors.verticalCenter: parent.verticalCenter
									width: appScrollView.width -appScrollView.effectiveScrollBarWidth -32

									Text {
										text: modelData.name
										color: GlobalVariables.colours.text
										font: GlobalVariables.font.regular
									}

									Text {
										visible: modelData.comment
										width: parent.width -GlobalVariables.controls.padding *2
										text: modelData.comment
										elide: Text.ElideRight
										color: GlobalVariables.colours.windowText
										font: GlobalVariables.font.small
									}
								}
							}
						}
					}

					// bottom padding element
					Item { Layout.preferredHeight: 1; }
				}
			}
		}
	}

	IpcHandler {
		target: "appdresser"
		function toggle(): void { popout.toggle(); }
	}
}
