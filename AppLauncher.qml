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
import "fuse.js" as FuseLib

Singleton { id: root
	function init() {}

	IpcHandler {
		target: "launcher"

		function open(): void { loader.active = true; }
		function close(): void { loader.active = false; }
		function toggle(): void { loader.active = !loader.active; }
	}

	FileView {
		path: Qt.resolvedUrl("./AppRankings.json")
		watchChanges: true
		onFileChanged: reload();
		onAdapterUpdated: writeAdapter();

		JsonAdapter { id: jsonAdapter
			property list<var> applications
		}
	}

	Loader { id: loader
		active: false
		sourceComponent: PanelWindow {
			anchors.top: true
			margins.top: screen.height /2.5 -header.height /2
			implicitWidth: screen.width /7
			implicitHeight: layout.height
			// mask: Region {}
			exclusionMode: ExclusionMode.Ignore
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
			WlrLayershell.namespace: "qs:launcher"
			color: "transparent"

			// Behavior on implicitHeight { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

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
										} else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
											list.currentIndex = list.currentIndex === list.count -1? 0 : list.currentIndex +1;
											event.accepted = true;
										} else if (event.key === Qt.Key_Escape) loader.active = false;
									}
									onAccepted: {
										if (list.currentItem) {
											list.currentItem.clicked(null);
										} else {
											Quickshell.execDetached(["sh", "-c", `${textInput.text}`]);
											loader.active = false;
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
					readonly property real opacityDuration: 150
					readonly property real translationDuration: 200

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
					add: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: list.opacityDuration; }}
					displaced: Transition {
						NumberAnimation { property: "y"; duration: list.translationDuration; easing.type: Easing.OutCubic; }
						NumberAnimation { property: "opacity"; to: 1; duration: list.opacityDuration; }
					}
					move: Transition {
						NumberAnimation { property: "y"; duration: list.translationDuration; easing.type: Easing.OutCubic; }
						NumberAnimation { property: "opacity"; to: 1; duration: list.opacityDuration; }
					}
					remove: Transition {
						NumberAnimation { property: "y"; duration: list.translationDuration; easing.type: Easing.OutCubic; }
						NumberAnimation { property: "opacity"; to: 0; duration: list.opacityDuration ; }
					}
					model: ScriptModel {
						values: {
							const countMin = Math.min(...jsonAdapter.applications.map(a => a.count));
							const countNormalDevisor = Math.max(...jsonAdapter.applications.map(a => a.count)) -countMin;
							const ageMin = Math.min(...jsonAdapter.applications.map(a => a.lastOpened)) -Date.now();
							const ageNormalDevisor = Math.max(...jsonAdapter.applications.map(a => a.lastOpened)) -Date.now() -ageMin
							const recencyWeight = 0.4;

							function calcRelevance(app, now = Date.now()) {
								const countNormal = (app.count -countMin) /countNormalDevisor;
								const ageNormal = (app.lastOpened -now -ageMin) /ageNormalDevisor;
								return recencyWeight *ageNormal +(1 -recencyWeight) *countNormal;
							}

							if (textInput.text) {
								const list = Array.from(DesktopEntries.applications.values) // list to search from
								.filter(a => !a.noDisplay) // remove entries that request to not be displayed
								.filter((obj, idx, item) => idx === item.findIndex(r => r.id === obj.id)) // dedupe list BUG

								const options = {
									keys: ["id", "name", "genericName", "keywords"],
									threshold: 0.4,
									includeScore: true,
									shouldSort: false
								};
								const fuse = new Fuse(list, options);

								return fuse.search(textInput.text).sort((a, b) => { // return search results sorted based on score and relevance
									const scoreWeight = 0.6;

									const a_App = jsonAdapter.applications.find(app => app.id === a.item.id);
									const b_App = jsonAdapter.applications.find(app => app.id === b.item.id);

									function calcWeightedMatch(app, score, now = Date.now()) {
										const relevance = calcRelevance(app);
										return scoreWeight *(1 -score) +(1 -scoreWeight) *relevance;
									}

									const a_weightedMatch = a_App? calcWeightedMatch(a_App, a.score) : null;
									const b_weightedMatch = b_App? calcWeightedMatch(b_App, b.score) : null;

									if (a_weightedMatch && b_weightedMatch) return b_weightedMatch -a_weightedMatch;
									else if (a_weightedMatch) return -1;
									else if (b_weightedMatch) return 1;
									else return a.score -b.score;
								})
								.map(r => r.item);
							} else {
								return Array.from(DesktopEntries.applications.values)
								.filter(a => !a.noDisplay)
								.filter((obj, idx, item) => idx === item.findIndex(r => r.id === obj.id))
								.sort((a, b) => { // sort based on relevance
									const a_App = jsonAdapter.applications.find(app => app.id === a.id);
									const b_App = jsonAdapter.applications.find(app => app.id === b.id);

									const a_Relevance = a_App? calcRelevance(a_App) : null;
									const b_Relevance = b_App? calcRelevance(b_App) : null;

									if (a_Relevance && b_Relevance) return b_Relevance -a_Relevance;
									else if (a_Relevance) return -1;
									else if (b_Relevance) return 1;
									else return a.name.localeCompare(b.name);
								});
							}
						}

						onValuesChanged: list.currentIndex = 0;
					}
					delegate: MouseArea {
						required property var modelData
						required property int index

						width: layout.width
						height: layout.height
						hoverEnabled: true
						onClicked: {
							modelData.execute();
							loader.active = false;
							if (jsonAdapter.applications.find(a => a.id === modelData.id)) {
								jsonAdapter.applications.find(a => a.id === modelData.id).count++;
								jsonAdapter.applications.find(a => a.id === modelData.id).lastOpened = Date.now();
							}else jsonAdapter.applications.push({
								"id": modelData.id,
								"count": 1,
								"lastOpened": Date.now()
							});
						}

						RowLayout { id: layout
							function setAlpha(colour, alpha) {
								return Qt.rgba(colour.r, colour.g, colour.b, alpha);
							}

							width: list.width
							layer.enabled: true
							layer.effect: ColorOverlay { color: {
								if (parent.containsMouse) return layout.setAlpha(GlobalVariables.colours.shadow, 0.2);
								else return "transparent";
							}}

							IconImage {
								Layout.leftMargin: GlobalVariables.controls.padding
								Layout.topMargin: GlobalVariables.controls.spacing /2
								Layout.bottomMargin: GlobalVariables.controls.spacing /2
								implicitSize: 28
								source: Quickshell.iconPath(modelData.name.toLowerCase(), true) || Quickshell.iconPath(modelData.icon, "image-missing")
							}

							Column {
								Layout.rightMargin: GlobalVariables.controls.padding
								Layout.fillWidth: true

								Row {
									spacing: 3

									Text {
										anchors.verticalCenter: parent.verticalCenter
										text: modelData.name
										color: GlobalVariables.colours.text
										font: GlobalVariables.font.regular
										verticalAlignment: Text.AlignVCenter
									}

									Text {
										visible: modelData.genericName
										anchors.verticalCenter: parent.verticalCenter
										text: `(${modelData.genericName})`
										color: GlobalVariables.colours.text
										font: GlobalVariables.font.smalleritalics
										verticalAlignment: Text.AlignVCenter
									}
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
