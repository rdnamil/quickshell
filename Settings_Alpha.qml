/*----------------------------------
--- Settings_Alpha.qml by andrel ---
----------------------------------*/

pragma Singleton

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.controls as Ctrl
import qs.styles as Style

Singleton { id: root
	function init() {}

	FloatingWindow { id: window
		visible: true
		title: "Qs Settings"
		minimumSize: "590x420"
		color: GlobalVariables.colours.dark

		RowLayout {
			anchors.fill: parent
			spacing: 0

			// pages
			ColumnLayout { id: pages
				readonly property var pageList: [
					["Wallpaper", "livewallpaper"],
					["Wallpaper", "livewallpaper"]
				]

				property int open: 0

				Layout.alignment: Qt.AlignTop
				Layout.fillHeight: true
				spacing: 4

				Repeater {
					model: pages.pageList
					delegate: Ctrl.QsButton {
						required property var modelData
						required property int index

						Layout.preferredWidth: parent.width
						Layout.minimumWidth: content.width
						Layout.topMargin: index === 0? 2 : 0
						shade: false
						anim: false
						highlight: true
						fill: pages.open === index;
						content: Row { id: content
							padding: GlobalVariables.controls.spacing
							spacing: GlobalVariables.controls.spacing
							// width: tab.width

							IconImage {
								implicitSize: 24
								source: Quickshell.iconPath(modelData[1])
							}

							Text {
								text: modelData[0]
								color: GlobalVariables.colours.text
								font.family: GlobalVariables.font.sans
								font.pointSize: 11
								font.weight: pages.open === index? 600 : 400
							}
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

			Loader {
				Layout.fillWidth: true
				Layout.fillHeight: true
				active: true
				sourceComponent: ColumnLayout { id: wallpaper
					readonly property var display: {
						if (displayDrop.selection === "All") return wallpapers[0];
						else return wallpapers.find(w => w.display === displayDrop.selection);
					}

					property list<var> wallpapers: []
					property color fill: GlobalVariables.colours.accent

					anchors.fill: parent

					// preview display
					Item { id: preview
						readonly property size resolution: wallpaper.display.resolution
						readonly property real aspect: resolution.width /resolution.height

						Layout.margins: GlobalVariables.controls.padding
						Layout.fillWidth: true
						Layout.fillHeight: true

						Rectangle {
							anchors.centerIn: parent
							width: Math.min(parent.width, parent.height *preview.aspect)
							height: width /preview.aspect
							radius: GlobalVariables.controls.radius
							color: GlobalVariables.colours.shadow

							Rectangle { id: previewContainer
								readonly property bool isPortrait: parent.height > parent.width

								anchors {
									left: parent.left
									leftMargin: {
										if (isPortrait) return (parent.width -width) *(2 /3);
										else return parent.width /2 -width /2;
									}
									top: parent.top
									topMargin: {
										if (isPortrait) return parent.height /2 -height /2;
										else return (parent.height -height) *(1 /3);
									}
								}
								width: parent.width -(isPortrait? 36 : 24)
								height: parent.height -(isPortrait? 24 : 36)
								color: wallpaper.fill
								layer.enabled: true
								layer.effect: OpacityMask {
									maskSource: Rectangle {
										width: previewContainer.width
										height: previewContainer.height
										radius: GlobalVariables.controls.radius /2
									}
								}

								Image {
									anchors.centerIn: parent
									width: {
										if (positionDrop.selection.toLowerCase() === "no") return parent.width *(sourceSize.width /preview.resolution.width);
										else return parent.width;
									}
									height: {
										if (positionDrop.selection.toLowerCase() === "no") return parent.height *(sourceSize.height /preview.resolution.height);
										else return parent.height;
									}
									source: wallpaper.display.path
									mipmap: true
									fillMode: switch (positionDrop.selection.toLowerCase()) {
										case "no":
											return Image.Stretch;
										case "crop":
											return Image.PreserveAspectCrop;
										case "fit":
											return Image.PreserveAspectFit;
										case "stretch":
											return Image.Stretch;
										default:
											return Image.PreserveAspectCrop;
									}
								}
							}
						}
					}

					// settings
					ColumnLayout {
						spacing: 0

						// display settings
						RowLayout {
							Layout.margins: GlobalVariables.controls.padding
							Layout.bottomMargin: 0
							spacing: GlobalVariables.controls.spacing

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
									options: ["All", ...wallpaper.wallpapers.map(w => w.display)]
									onSelected: (option) => { selection = option; }
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
										text: wallpaper.display.path
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
											text: wallpaper.display.path
											color: GlobalVariables.colours.windowText
											font: GlobalVariables.font.regular
											elide: Text.ElideLeft
										}
									}
								}

								Ctrl.QsButton {
									anim: false
									tooltip: Text {
										text: "Browse files"
										color: GlobalVariables.colours.text
										font: GlobalVariables.font.regular
									}
									content: Style.Button {
										width: fileSelectionText.width
										height: 24
										invert: parent.parent.isPressed

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
							spacing: GlobalVariables.controls.spacing

							// wallpaper position
							RowLayout {
								Text {
									text: "Position:"
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.regular
								}

								Ctrl.QsDropdown { id: positionDrop
									Layout.fillWidth: true
									options: ['No', 'Crop', 'Fit', 'Stretch']
									selection: 'Crop'
									onSelected: (option) => { selection = option; }
								}
							}

							// spacer
							Item { Layout.preferredWidth: GlobalVariables.controls.padding; }

							// fill colour
							RowLayout {
								Text {
									text: "Colour:"
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.regular
								}

								Ctrl.QsButton { id: fillColourBtn
									anim: false
									shade: false
									content: Rectangle {
										width: 24
										height: width
										radius: height /2
										color: wallpaper.fill
										border { width: 2; color: GlobalVariables.colours.midlight; }
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
									options: ['None', 'Simple', 'Fade', 'Left', 'Right', 'Top', 'Bottom', 'Wipe', 'Wave', 'Grow', 'Center', 'Any', 'Outer', 'Random']
									selection: 'Wave'
									onSelected: (option) => { selection = option; }
								}
							}
						}
					}

					// apply changes
					Ctrl.QsButton {
						Layout.alignment: Qt.AlignRight | Qt.AlignBottom
						Layout.margins: GlobalVariables.controls.padding
						anim: false
						tooltip: Text {
							text: "Apply changes"
							color: GlobalVariables.colours.text
							font: GlobalVariables.font.regular
						}
						content: Style.Button {
							width: applyText.contentWidth +GlobalVariables.controls.padding *2
							height: applyText.contentHeight +GlobalVariables.controls.padding
							invert: parent.parent.isPressed

							Text { id: applyText
								anchors.centerIn: parent
								text: "Apply"
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.regular
								verticalAlignment: Text.AlignVCenter
							}
						}
					}

					Process { id: getWallpaper
						running: true
						command: ['swww', 'query']
						stdout: StdioCollector {
							onStreamFinished: {
								var ws = text.trim().split('\n');

								wallpaper.wallpapers = [];

								for (let w of ws) {
									const parts = w.match(/^:\s*(\S+):\s*([^,]+),\s*scale:\s*(\d+),\s*currently displaying:\s*(\w+):\s*(.+)$/);

									if (!parts) continue;

									wallpaper.wallpapers.push({
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
