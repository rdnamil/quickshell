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
					readonly property var display: wallpapers[0]

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
								anchors {
									horizontalCenter: parent.horizontalCenter
									top: parent.top
									topMargin: (parent.height -height) /3
								}
								width: parent.width -24
								height: parent.height -36
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
										if (positionDropdown.selection.toLowerCase() === "no") return parent.width *(sourceSize.width /preview.resolution.width);
										else return parent.width;
									}
									height: {
										if (positionDropdown.selection.toLowerCase() === "no") return parent.height *(sourceSize.height /preview.resolution.height);
										else return parent.height;
									}
									source: wallpaper.display.path
									mipmap: true
									fillMode: switch (positionDropdown.selection.toLowerCase()) {
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
						RowLayout {
							Layout.margins: GlobalVariables.controls.padding
							spacing: GlobalVariables.controls.spacing

							RowLayout {
								Text {
									text: "Position:"
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.regular
								}

								Ctrl.QsDropdown { id: positionDropdown
									Layout.fillWidth: true
									options: ['No', 'Crop', 'Fit', 'Stretch']
									selection: 'Crop'
									onSelected: (option) => { selection = option; }
								}
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
