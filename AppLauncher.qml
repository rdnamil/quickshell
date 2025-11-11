/*-------------------------------
--- AppLauncher.qml by andrel ---
-------------------------------*/

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.styles as Style

Singleton { id: root
	function init() {}

	IpcHandler {
		target: "launcher"

		function open(): void { loader.active = true; }
		function close(): void { loader.active = false; }
		function toggle(): void { loader.active = !loader.active; }
	}

	Loader { id: loader
		active: false
		sourceComponent: PanelWindow {
			anchors.top: true
			margins.top: screen.height /2.5
			implicitWidth: screen.width /7
			implicitHeight: layout.height
			// mask: Region {}
			exclusionMode: ExclusionMode.Ignore
			// WlrLayershell.layer: WlrLayer.Surface
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
			WlrLayershell.namespace: "qs:launcher"
			color: "transparent"

			Behavior on implicitHeight { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

			Rectangle {
				anchors {
					top: parent.top
					topMargin: header.height -GlobalVariables.controls.radius
				}
				width: parent.width
				height: parent.height -header.height +GlobalVariables.controls.radius
				radius: GlobalVariables.controls.radius
				color: GlobalVariables.colours.dark
			}

			ColumnLayout { id: layout
				width: parent.width

				Rectangle { id: header
					Layout.fillWidth: true
					Layout.preferredHeight: textField.height +GlobalVariables.controls.padding *2
					color: "transparent"
					layer.enabled: true
					layer.effect: OpacityMask {
						maskSource: Rectangle {
							width: header.width
							height: header.height
							topLeftRadius: GlobalVariables.controls.radius
							topRightRadius: GlobalVariables.controls.radius
						}
					}

					Style.Borders {}

					Rectangle {
						width: parent.width
						height: parent.height -2
						color: GlobalVariables.colours.base
					}

					Rectangle { id: textField
						anchors.centerIn: parent
						width: parent.width -GlobalVariables.controls.padding *2
						height: textFieldLayout.height +GlobalVariables.controls.spacing
						radius: GlobalVariables.controls.radius
						color: GlobalVariables.colours.dark

						Style.Borders { opacity: 0.4; }

						RowLayout { id: textFieldLayout
							anchors.centerIn: parent
							width: parent.width

							IconImage {
								Layout.margins: 3
								Layout.leftMargin: GlobalVariables.controls.spacing
								Layout.rightMargin: 0
								implicitSize: GlobalVariables.controls.iconSize
								source: Quickshell.iconPath("search")
								layer.enabled: true
								layer.effect: ColorOverlay {
									color: GlobalVariables.colours.text
								}
							}

							Item {
								Layout.margins: 3
								Layout.leftMargin: 0
								Layout.rightMargin: GlobalVariables.controls.spacing
								Layout.fillWidth: true
								Layout.preferredHeight: textInput.height

								Text {
									visible: !textInput.text
									text: " Start typing..."
									color: GlobalVariables.colours.windowText
									font: GlobalVariables.font.italic
									opacity: 0.4
								}

								TextInput { id: textInput
									width: parent.width
									clip: true
									focus: true
									// Keys.forwardTo: [list]
									Keys.onPressed: event => {
										if (event.key === Qt.Key_Up) {
											list.currentIndex = list.currentIndex === 0? list.count -1 : list.currentIndex -1;
											event.accepted = true;
										} else if (event.key === Qt.Key_Down) {
											list.currentIndex = list.currentIndex === list.count -1? 0 : list.currentIndex +1;
											event.accepted = true;
										} else if (event.key === Qt.Key_Escape) loader.active = false;
									}
									onAccepted: {
										if (list.currentItem) {
											list.currentItem.clicked(null);
										}
									}
									onTextChanged: list.currentIndex = 0;
									font: GlobalVariables.font.regular
									color: GlobalVariables.colours.text
								}
							}
						}
					}
				}

				ListView { id: list
					Layout.fillWidth: true
					Layout.minimumHeight: 28 +GlobalVariables.controls.spacing
					Layout.preferredHeight: contentHeight
					Layout.maximumHeight: screen.height /4
					Layout.bottomMargin: GlobalVariables.controls.padding
					clip: true
					spacing: GlobalVariables.controls.spacing /2
					// snapMode: ListView.SnapToItem
					preferredHighlightBegin: 0
					preferredHighlightEnd: height
					highlightRangeMode: ListView.ApplyRange
					highlightMoveDuration: 250
					highlight: Rectangle {
						color: GlobalVariables.colours.accent
						opacity: 0.4
					}
					model: ScriptModel {
						// values: Array.from(DesktopEntries.applications.values).sort((a, b) => a.name.localeCompare(b.name));
						values: DesktopEntries.applications.values
						.map(object => {
							const stxt = textInput.text.toLowerCase();
							const ntxt = object.name.toLowerCase();
							let si = 0;
							let ni = 0;

							let matches = [];
							let startMatch = -1;

							for (let si = 0; si != stxt.length; ++si) {
								const sc = stxt[si];

								while (true) {
									// Drop any entries with letters that don't exist in order
									if (ni == ntxt.length) return null;

									const nc = ntxt[ni++];

									if (nc == sc) {
										if (startMatch == -1) startMatch = ni;
										break;
									} else {
										if (startMatch != -1) {
											matches.push({
												index: startMatch,
												length: ni - startMatch,
											});

											startMatch = -1;
										}
									}
								}
							}

							if (startMatch != -1) {
								matches.push({
									index: startMatch,
									length: ni - startMatch + 1,
								});
							}

							return {
								object: object,
								matches: matches,
							};
						})
						.filter(entry => entry !== null)
						.sort((a, b) => {
							let ai = 0;
							let bi = 0;
							let s = 0;

							while (ai != a.matches.length && bi != b.matches.length) {
								const am = a.matches[ai];
								const bm = b.matches[bi];

								s = bm.length - am.length;
								if (s != 0) return s;

								s = am.index - bm.index;
								if (s != 0) return s;

								++ai;
								++bi;
							}

							s = a.matches.length - b.matches.length;
							if (s != 0) return s;

							s = a.object.name.length - b.object.name.length;
							if (s != 0) return s;

							return a.object.name.localeCompare(b.object.name);
						})
						.map(entry => entry.object);

						onValuesChanged: list.currentIndex = 0
					}
					delegate: MouseArea {
						required property var modelData
						required property int index

						width: layout.width
						height: layout.height
						onClicked: {
							modelData.execute();
							loader.active = false;
						}

						RowLayout { id: layout
							width: list.width

							IconImage {
								Layout.leftMargin: GlobalVariables.controls.padding
								Layout.topMargin: GlobalVariables.controls.spacing /2
								Layout.bottomMargin: GlobalVariables.controls.spacing /2
								implicitSize: 28
								source: Quickshell.iconPath(modelData.id, true) || Quickshell.iconPath(modelData.icon, "image-missing")
							}

							Column {
								Layout.rightMargin: GlobalVariables.controls.padding
								Layout.fillWidth: true

								Text {
									text: modelData.name
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.regular
								}

								Text {
									visible: modelData.comment
									width: parent.width
									text: modelData.comment
									elide: Text.ElideRight
									color: GlobalVariables.colours.windowText
									font: GlobalVariables.font.smaller
								}
							}
						}
					}
				}
			}


		}
	}
}
