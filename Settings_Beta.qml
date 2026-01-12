/*-----------------------------
--- Wallpaper.qml by andrel ---
-----------------------------*/

pragma Singleton

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.controls as Ctrl
import qs.styles as Style

Singleton { id: root
	property string display

	function init() {}

	FloatingWindow { id: window
		// visible: false
		title: "Qs Settings - Wallpaper"
		color: GlobalVariables.colours.dark;

		RowLayout {
			anchors.fill: parent
			spacing: 0

			// pages
			ColumnLayout {
				Layout.alignment: Qt.AlignTop
				// Layout.topMargin: GlobalVariables.controls.padding
				// spacing: GlobalVariables.controls.spacing
				Layout.fillHeight: true
				spacing: 0

				Ctrl.QsButton {
					highlight: true
					shade: false
					clip: true
					fill: true
					content: Row { id: wallpaper
						padding: GlobalVariables.controls.spacing
						spacing: GlobalVariables.controls.spacing

						IconImage {
							implicitSize: 24
							source: Quickshell.iconPath("livewallpaper")
						}

						Text {
							anchors.verticalCenter: parent.verticalCenter
							text: "Wallpaper"
							color: GlobalVariables.colours.text
							font.family: GlobalVariables.font.sans
							font.pointSize: 11
							font.weight: 600
						}
					}
				}
			}

			// devider
			Rectangle {
				Layout.fillHeight: true
				width: 1
				color: GlobalVariables.colours.midlight
			}

			// load settings page
			Loader {
				Layout.fillWidth: true
				Layout.fillHeight: true
				active: true
				sourceComponent: ColumnLayout { id: wallpaperSettings
					readonly property url currentWallPath: {
						if (displayDrop.selection === "All") return wallpaperSettings.wall[0].path;
						else return wallpaperSettings.wall.find(w => w.display === displayDrop.selection).path;
					}

					property list<var> wall
					property bool lockFileSelection
					property bool lockColourSelection
					property Item whosOpen

					signal dropOpened()

					spacing: 0
					width: parent.width
					height: parent.height

					Process { id: getWall
						running: true
						command: ['swww', 'query']
						stdout: StdioCollector {
							onStreamFinished: {
								var ws = text.trim().split('\n');

								wallpaperSettings.wall = []

								for (let w of ws) {
									const parts = w.match(/^:\s*(\S+):\s*([^,]+),\s*scale:\s*(\d+),\s*currently displaying:\s*(\w+):\s*(.+)$/);

									if (!parts) continue;

									wallpaperSettings.wall.push({
										display: parts[1],
										resolution: parts[2],
										scale: parts[3],
										type: parts[4],
										path: parts[5]
									});
								}
							}
						}
					}

					Process { id: setWall
						onRunningChanged: { if (running) lockFileSelection = true; else lockFileSelection = false; }
						command: ['zenity', '--file-selection']
						stdout: StdioCollector {
							onStreamFinished: {
								if (text.trim()) {
									if (displayDrop.selection === "All") wallpaperSettings.wall[0].path = text.trim();
									else wallpaperSettings.wall.find(w => w.display === displayDrop.selection).path = text.trim();

									console.log(`Settings: Wallpaper on ${displayDrop.selection} changed to ${wallpaperSettings.wall.find(w => w.display === displayDrop.selection).path}`);
								}
							}
						}
					}

					Process { id: applyWall
						command: {
							if (displayDrop.selection === "All") return ['swww', 'img', '--resize',resizeDrop.selection, '--fill-color', fillColourBtn.fillColour.toString().replace('#', ''), '-t', transDrop.selection, '--transition-fps', '60', wallpaperSettings.currentWallPath];
							else return ['swww', 'img',  '-o', displayDrop.selection, '--resize', resizeDrop.selection, '--fill-color', fillColourBtn.fillColour.toString().replace('#', ''), '-t', transDrop.selection, '--transition-fps', '60', wallpaperSettings.currentWallPath];
						}
						stdout: StdioCollector { onStreamFinished: getWall.running = true; }
					}

					Process { id: getColour
						onRunningChanged: { if (running) lockColourSelection = true; else lockColourSelection = false; }
						command: ['yad', '--color']
						stdout: StdioCollector { onStreamFinished: { if (text.trim()) fillColourBtn.fillColour = text.trim(); }}
					}

					ColumnLayout {
						Layout.alignment: Qt.AlignTop
						spacing: 0

						// display and wall settings
						RowLayout {
							Layout.margins: GlobalVariables.controls.padding
							Layout.bottomMargin: 0
							spacing: 0

							// select display
							RowLayout {
								Text {
									text: "Display:"
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.regular
								}

								Ctrl.QsDropdown { id: displayDrop
									Layout.fillWidth: true
									Layout.minimumWidth: 64
									selection: "All"
									options: ["All", ...Quickshell.screens.map(s => s.name)]
									onSelected: (option) => { selection = option; }
									onOpened: {
										whosOpen = displayDrop;
										wallpaperSettings.dropOpened();
									}

									Connections {
										target: wallpaperSettings
										function onDropOpened() { if (whosOpen !== displayDrop) displayDrop.close(); }
									}
								}
							}

							// spacer
							Item { Layout.preferredWidth: GlobalVariables.controls.padding; }

							// wallpaper path/selection
							RowLayout {
								Text {
									text: "Wallpaper:"
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.regular
								}

								Ctrl.QsButton {
									Layout.fillWidth: true
									Layout.minimumWidth: 128
									anim: false
									shade: false
									tooltip: Text {
										text: wallpaperSettings.currentWallPath
										color: GlobalVariables.colours.text
										font: GlobalVariables.font.regular
									}
									content: Style.Button {
										width: parent.parent.width
										invert: true

										Text {
											anchors.verticalCenter: parent.verticalCenter
											width: parent.width
											leftPadding: GlobalVariables.controls.padding
											rightPadding: GlobalVariables.controls.padding
											text: wallpaperSettings.currentWallPath
											color: GlobalVariables.colours.windowText
											font: GlobalVariables.font.regular
											elide: Text.ElideLeft
										}
									}
								}

								Ctrl.QsButton {
									onClicked: {
										whosOpen = null;
										wallpaperSettings.dropOpened();
										if (!lockFileSelection) setWall.running = true;
									}
									content: Style.Button {
										width: fileSelectionText.width
										height: 24

										Text { id: fileSelectionText
											leftPadding: GlobalVariables.controls.spacing
											rightPadding: GlobalVariables.controls.spacing
											text: "..."
											color: GlobalVariables.colours.text
											font: GlobalVariables.font.regular
										}
									}
								}
							}
						}

						// swww settings
						RowLayout {
							Layout.margins: GlobalVariables.controls.padding
							Layout.bottomMargin: 0
							spacing: GlobalVariables.controls.spacing

							// fill mode
							RowLayout {
								Text {
									text: "Resize:"
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.regular
								}

								Ctrl.QsDropdown { id: resizeDrop
									Layout.fillWidth: true
									options: ['no', 'crop', 'fit', 'stretch']
									selection: 'crop'
									onSelected: (option) => { selection = option; }
									onOpened: {
										whosOpen = resizeDrop;
										wallpaperSettings.dropOpened();
									}

									Connections {
										target: wallpaperSettings
										function onDropOpened() { if (whosOpen !== resizeDrop) resizeDrop.close(); }
									}
								}
							}

							// spacer
							Item { Layout.preferredWidth: GlobalVariables.controls.padding; }

							// fill colour
							RowLayout {
								Text {
									text: "Fill colour:"
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.regular
								}

								Ctrl.QsButton { id: fillColourBtn
									property color fillColour: "white"

									onClicked: {
										whosOpen = null;
										wallpaperSettings.dropOpened();
										if (!lockColourSelection) getColour.running = true;
									}
									anim: false
									shade: false
									content: Rectangle {
										width: 24
										height: width
										radius: height /2
										color: fillColourBtn.fillColour
										border { width: 2; color: GlobalVariables.colours.accent; }
									}
								}
							}

							// spacer
							Item { Layout.preferredWidth: GlobalVariables.controls.padding; }

							// transition
							RowLayout {
								Text {
									text: "Transition:"
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.regular
								}

								Ctrl.QsDropdown { id: transDrop
									Layout.fillWidth: true
									options: ['none', 'simple', 'fade', 'left', 'right', 'top', 'bottom', 'wipe', 'wave', 'grow', 'center', 'any', 'outer', 'random']
									selection: 'wave'
									onSelected: (option) => { selection = option; }
									onOpened: {
										whosOpen = transDrop;
										wallpaperSettings.dropOpened();
									}

									Connections {
										target: wallpaperSettings
										function onDropOpened() { if (whosOpen !== transDrop) transDrop.close(); }
									}
								}
							}
						}
					}

					// preview wallpaper
					Image { id: preview
						Layout.alignment: Qt.AlignHCenter
						Layout.margins: GlobalVariables.controls.padding
						Layout.fillWidth: true
						Layout.maximumWidth: sourceSize.width
						Layout.fillHeight: true
						Layout.maximumHeight: Math.min(sourceSize.height, (sourceSize.height /sourceSize.width *width))

						source: wallpaperSettings.currentWallPath
						fillMode: Image.PreserveAspectFit
						mipmap: true

						Rectangle {
							anchors.centerIn: parent
							width: parent.paintedWidth +2
							height: parent.paintedHeight +2
							color: "transparent"
							border { width: 4; color: GlobalVariables.colours.accent; }
						}

						// Text {
						// 	text: `${parent.width}x${parent.height}`
						// 	color: GlobalVariables.colours.text
						// 	font: GlobalVariables.font.regular
						// }
					}

					// apply changes
					Ctrl.QsButton { id: applyBtn
						Layout.alignment: Qt.AlignRight | Qt.AlignBottom
						Layout.margins: GlobalVariables.controls.padding
						onClicked: applyWall.running = true;
						content: Style.Button {
							width: applyText.contentWidth +GlobalVariables.controls.padding
							height: applyText.contentHeight +GlobalVariables.controls.padding
							invert: applyBtn.isPressed

							Text { id: applyText
								anchors.centerIn: parent
								text: "Apply"
								color: GlobalVariables.colours.text
								font.family: GlobalVariables.font.sans
								font.pointSize: 11
								font.weight: 600
								verticalAlignment: Text.AlignVCenter
							}
						}
					}
				}

				Rectangle { anchors.fill: parent; color: GlobalVariables.colours.window; }
			}
		}
	}

	IpcHandler {
		target: "settings"
		function launch(): void { window.visible = true; }
	}
}
