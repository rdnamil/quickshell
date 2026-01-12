/*-------------------------------
--- AppLauncher.qml by andrel ---
-------------------------------*/

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import qs.controls as Ctrl
import qs.styles as Style
import "fuse.js" as FuseLib

Singleton { id: root
	property int maxLines
	property bool hideFilters

	function init(lines = 10, hidden = false) {
		root.maxLines = lines;
		root.hideFilters = hidden;
	}

	// close the launcher
	function close() {
		fileView.writeAdapter(); // write changes to file
		loader.active = false; // unload the launcher
	}

	IpcHandler {
		target: "launcher"

		function open(): void { loader.active = true; }
		function close(): void { loader.active = false; }
		function toggle(): void { loader.active = !loader.active; }
	}

	// keep properties stored for persistence
	FileView { id: fileView
		path: Qt.resolvedUrl("./AppRankings.json")
		watchChanges: true
		onFileChanged: reload();
		// onAdapterUpdated: writeAdapter();

		JsonAdapter { id: jsonAdapter
			property list<var> applications
		}
	}

	Loader { id: loader
		active: true
		sourceComponent: PanelWindow { id: launcher
			anchors.top: true
			margins.top: screen.height /2.5 -header.height /2
			exclusionMode: ExclusionMode.Ignore
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
			WlrLayershell.namespace: "qs:launcher"
			implicitWidth: screen.width *(1 /6)
			implicitHeight: layout.height
			color: "transparent"

			// click outside launcher to close
			PanelWindow {
				anchors {
					left: true
					right: true
					top: true
					bottom: true
				}
				// color: "#10ff0000"
				color: "transparent"

				MouseArea {
					anchors.fill: parent
					onClicked: loader.active = false;
				}
			}

			Column { id: layout
				spacing: -1
				width: screen.width *(1 /6)

				Rectangle { id: header
					readonly property TextMetrics textMetrics: TextMetrics {
						font: GlobalVariables.font.regular
						text: "test"
					}

					width: parent.width
					height: headerLayout.height
					topLeftRadius: GlobalVariables.controls.radius
					topRightRadius: GlobalVariables.controls.radius
					color: GlobalVariables.colours.base

					ColumnLayout { id: headerLayout
						anchors.horizontalCenter: parent.horizontalCenter
						width: parent.width -GlobalVariables.controls.padding *2

						// top spacer
						Item { Layout.preferredHeight: GlobalVariables.controls.padding -parent.spacing; }

						// searchbar
						Rectangle {
							// Layout.margins: GlobalVariables.controls.padding
							Layout.fillWidth: true
							height: searchLayout.height
							radius: GlobalVariables.controls.radius *(2 /3)
							color: GlobalVariables.colours.dark
							border { width: 2; color: GlobalVariables.colours.light; }

							Rectangle { anchors.fill: parent; radius: parent.radius; color: "transparent"; border { width: 1; color: GlobalVariables.colours.dark; }}

							RowLayout { id: searchLayout
								spacing: 0
								width: parent.width

								IconImage {
									Layout.leftMargin: GlobalVariables.controls.spacing
									implicitSize: GlobalVariables.controls.iconSize
									source: Quickshell.iconPath("search")
								}

								TextInput { id: textInput
									readonly property Component cursorRect: Rectangle { id: cursor
										width: 1
										height: textInput.height
										opacity: textInput.blink? 0.0 : 1.0
									}

									property bool blink

									Layout.margins: GlobalVariables.controls.spacing /2
									Layout.fillWidth: true
									clip: true
									focus: true
									Keys.onPressed: event => {
										scrollBar.active = true;

										// use arrow keys and tab to navigate entries
										if (event.key === Qt.Key_Up) listView.decrementCurrentIndex();
										else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) listView.incrementCurrentIndex();
										else if (event.key === Qt.Key_Escape) root.close();
										// use ctrl+p to pin entry
										else if ((event.key === Qt.Key_P) && (event.modifiers & Qt.ControlModifier)) listView.currentItem.pin();
									}
									onAccepted: switch (true) {
										case listView.currentItem !== null:
											listView.currentItem.clicked(null);
											break;
										default:
											root.close();
											break;
									}
									onTextChanged: {
										listView.currentIndex = 0;
										blinkInterval.restart();
										blink = false;

										// set listView filter enum
										if (text) listView.filter = 2;
										else listView.filter = 0;
									}
									font: GlobalVariables.font.regular
									color: GlobalVariables.colours.text
									// color: "transparent"
									cursorDelegate: cursorRect

									Timer { id: blinkInterval
										running: true
										repeat: true
										interval: 500
										onTriggered: parent.blink = !parent.blink
									}

									// display text
									// Text {
									// 	text: parent.displayText
									// 	color: GlobalVariables.colours.text
									// 	font: GlobalVariables.font.regular
									// }

									// placeholder text
									Text {
										visible: !parent.displayText
										width: parent.width
										height: parent.height
										verticalAlignment: Text.AlignVCenter
										text: "Start typing..."
										font: GlobalVariables.font.italic
										color: GlobalVariables.colours.windowText
										opacity: 0.4
									}
								}
							}
						}

						// categories
						RowLayout { id: cats
							readonly property var cats: [
								["Development", "applications-development-symbolic", "Development"],
								["Education", "applications-education-symbolic", "Education"],
								["Games", "applications-games-symbolic", "Game"],
								["Internet", "applications-internet-symbolic", "Network"],
								["Multimedia", "applications-multimedia-symbolic", "Player"],
								["Utilities", "applications-utilities-symbolic", "Utility"]
							]

							property var cat

							visible: !root.hideFilters
							spacing: 3

							Ctrl.QsButton { id: clear
								Layout.fillWidth: true
								onClicked: listView.filter = 0;
								tooltip: Text {
									text: "All applications"
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.regular
								}
								content: Style.Button {
									width: clear.width
									invert: listView.filter === 0

									IconImage {
										anchors.centerIn: parent
										implicitSize: GlobalVariables.controls.iconSize
										source: Quickshell.iconPath("applications-all-symbolic")
									}
								}
							}

							Repeater {
								model: cats.cats
								delegate: Ctrl.QsButton { id: filter
									required property var modelData

									Layout.fillWidth: true
									onClicked: {
										listView.filter = 1;
										cats.cat = modelData[2];
									}
									tooltip: Text {
										text: modelData[0]
										color: GlobalVariables.colours.text
										font: GlobalVariables.font.regular
									}
									content: Style.Button {
										width: filter.width
										invert: (cats.cat === modelData[2]) && (listView.filter === 1)

										IconImage {
											anchors.centerIn: parent
											implicitSize: GlobalVariables.controls.iconSize
											source: Quickshell.iconPath(modelData[1])
										}
									}
								}
							}
						}

						// bottom spacer
						Item { Layout.preferredHeight: GlobalVariables.controls.padding -parent.spacing; }
					}
				}

				ScrollView { id: scrollView
					width: parent.width
					height: Math.min((32 +GlobalVariables.controls.spacing) *root.maxLines +4, listView.contentHeight +GlobalVariables.controls.padding +4)
					topPadding: GlobalVariables.controls.padding
					ScrollBar.vertical: ScrollBar { id: scrollBar
						anchors {
							// right: parent.right
							// rightMargin: scrollBar.pressed? 3 : 4
							top: parent.top
							topMargin: GlobalVariables.controls.spacing /2
						}
						x: parent.width -width /2 -6
						height: parent.availableHeight -GlobalVariables.controls.spacing
						contentItem: Rectangle {
							implicitWidth: scrollBar.pressed || scrollBar.hovered? 6 : 4
							radius: width /2
							color: scrollBar.pressed? GlobalVariables.colours.text : GlobalVariables.colours.windowText
							opacity: (scrollBar.active && scrollBar.size < 1.0) ? 0.75 : 0

							Behavior on opacity { NumberAnimation { duration: 250; }}
							Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.OutCubic; }}
						}
					}
					background: Rectangle {
						anchors.fill: parent
						// bottomLeftRadius: GlobalVariables.controls.radius
						// bottomRightRadius: GlobalVariables.controls.radius
						color: GlobalVariables.colours.dark

						Rectangle {
							anchors {
								horizontalCenter: parent.horizontalCenter
								top: parent.top
							}
							width: parent.width -2
							height: 1
							color: GlobalVariables.colours.light
						}
					}

					ListView { id: listView
						readonly property real opacityDuration: 150
						readonly property real translationDuration: 200

						property int filter: 0

						clip: true
						spacing: GlobalVariables.controls.spacing
						preferredHighlightBegin: 0
						preferredHighlightEnd: height
						highlightRangeMode: ListView.ApplyRange
						highlightFollowsCurrentItem: false
						highlight: Rectangle {
							y: listView.currentItem.y -2
							width: listView.currentItem.width
							height: listView.currentItem.height +4
							color: GlobalVariables.colours.accent
							opacity: 0.4

							Behavior on y { NumberAnimation{ duration: 250; easing.type: Easing.OutCubic; }}
						}
						keyNavigationWraps: true
						boundsBehavior: Flickable.StopAtBounds
						add: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: listView.opacityDuration; }}
						displaced: Transition {
							NumberAnimation { property: "y"; duration: listView.translationDuration; easing.type: Easing.OutCubic; }
							NumberAnimation { property: "opacity"; to: 1; duration: listView.opacityDuration; }
						}
						move: Transition {
							NumberAnimation { property: "y"; duration: listView.translationDuration; easing.type: Easing.OutCubic; }
							NumberAnimation { property: "opacity"; to: 1; duration: listView.opacityDuration; }
						}
						remove: Transition {
							NumberAnimation { property: "y"; duration: listView.translationDuration; easing.type: Easing.OutCubic; }
							NumberAnimation { property: "opacity"; to: 0; duration: listView.opacityDuration ; }
						}
						model: ScriptModel { id: model
							values: {
								let list = Array.from(DesktopEntries.applications.values) // list to search from
								.filter(a => !a.noDisplay) // remove entries that request to not be displayed
								.filter((obj, idx, item) => idx === item.findIndex(r => r.id === obj.id)) // dedupe list BUG

								const countMin = Math.min(...jsonAdapter.applications.filter(a => a.count).map(a => a.count));
								const countNormalDevisor = Math.max(...jsonAdapter.applications.filter(a => a.count).map(a => a.count)) -countMin;
								const ageMin = Math.min(...jsonAdapter.applications.filter(a => a.lastOpened).map(a => a.lastOpened)) -Date.now();
								const ageNormalDevisor = Math.max(...jsonAdapter.applications.filter(a => a.lastOpened).map(a => a.lastOpened)) -Date.now() -ageMin
								const recencyWeight = 0.4;

								function calcRelevance(app, now = Date.now()) {
									const countNormal = (app.count -countMin) /countNormalDevisor;
									const ageNormal = (app.lastOpened -now -ageMin) /ageNormalDevisor;
									return recencyWeight *ageNormal +(1 -recencyWeight) *countNormal;
								}

								const relevanceMap = new Map(
									jsonAdapter.applications.map(app => [app.id, calcRelevance(app)])
								);

								switch (true) {
									case textInput.text.length > 0:
										const options = {
											keys: ["id", "name", "genericName", "keywords"],
											threshold: 0.4,
											includeScore: true,
											shouldSort: true
										};
										const fuse = new Fuse(list, options);

										return fuse.search(textInput.text).map(r => r.item);
										break;
									case listView.filter === 1:
										return list
										.filter(a => a.categories.includes(cats.cat))
										.sort((a, b) => {
											// sort alphabetically
											return a.name.localeCompare(b.name);
										});
										break;
									default:
										return list
										.sort((a, b) => {
											const a_App = jsonAdapter.applications.find(app => app.id === a.id);
											const b_App = jsonAdapter.applications.find(app => app.id === b.id);

											const a_Fav = a_App? a_App.isFavourite : null;
											const b_Fav = b_App? b_App.isFavourite : null;

											// move favourites to top of the list
											if (a_Fav && b_Fav) return b_Fav -a_Fav;
											else if (a_Fav) return -1;
											else if (b_Fav) return 1;

											// sort by relevance
											const a_Relevance = relevanceMap.get(a.id);
											const b_Relevance = relevanceMap.get(b.id);

											if (a_Relevance && b_Relevance) { return b_Relevance -a_Relevance; console.log("debug") }
											else if (a_Relevance) return -1;
											else if (b_Relevance) return 1;

											// sort alphabetically
											return a.name.localeCompare(b.name);
										});
										break;
								}
							}
							onValuesChanged: listView.currentIndex = 0;
							objectProp: "id"
						}
						delegate: Ctrl.QsButton { id: application
							required property var modelData

							readonly property var isFavourite: jsonAdapter.applications.find(a => a.id === modelData.id)?.isFavourite || false

							signal pin()

							onPin: {
								// add an etry if none exist
								if (!jsonAdapter.applications.find(a => a.id === modelData.id)) {
									jsonAdapter.applications.push({
										"id": modelData.id,
										"isFavourite": Date.now()
									});
									// console.log("Startmenu: Added entry.");
									// update entry if there's already one
								} else {
									jsonAdapter.applications.find(a => a.id === modelData.id).isFavourite = isFavourite? null : Date.now();
									// console.log("Startmenu: Updated entry.");
								}
							}
							onClicked: {
								// add an etry if none exist
								if (!jsonAdapter.applications.find(a => a.id === modelData.id)) {
									jsonAdapter.applications.push({
										"id": modelData.id,
										"count": 1,
										"lastOpened": Date.now()
									});
									// console.log("Startmenu: Added entry.");
									// update entry if there's already one
								} else {
									jsonAdapter.applications.find(a => a.id === modelData.id).count += 1;
									jsonAdapter.applications.find(a => a.id === modelData.id).lastOpened = Date.now();
									// console.log("Startmenu: Updated entry.");
								}
								modelData.execute();
								root.close();
							}
							content: RowLayout {
								width: scrollView.availableWidth

								IconImage {
									Layout.leftMargin: GlobalVariables.controls.padding
									backer.cache: true
									implicitSize: 32
									source: Quickshell.iconPath(modelData.name.toLowerCase(), modelData.icon)
								}

								Column {
									Layout.rightMargin: GlobalVariables.controls.padding
									Layout.fillWidth: true

									RowLayout {
										width: parent.width

										Text {
											text: modelData.name
											color: GlobalVariables.colours.text
											font: GlobalVariables.font.regular
										}

										Text {
											visible: modelData.genericName
											Layout.fillWidth: true
											text: `(${modelData.genericName})`
											elide: Text.ElideRight
											color: GlobalVariables.colours.text
											font: GlobalVariables.font.smallitalics
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

								Item { visible: pin.visible; Layout.preferredWidth: 24 +GlobalVariables.controls.padding; }
							}

							Ctrl.QsButton { id: pin
								visible: containsMouse || parent.containsMouse || isFavourite
								anchors {
									right: parent.right
									rightMargin: GlobalVariables.controls.padding
									verticalCenter: parent.verticalCenter
								}
								onClicked: parent.pin();
								content: IconImage {
									implicitSize: 24
									source: Quickshell.iconPath("pin")
								}
							}
						}
					}
				}

				Rectangle { id: footer
					width: parent.width
					height: footerLayout.height
					bottomLeftRadius: GlobalVariables.controls.radius
					bottomRightRadius: GlobalVariables.controls.radius
					color: GlobalVariables.colours.dark

					Row { id: footerLayout
						padding: GlobalVariables.controls.spacing
						spacing: GlobalVariables.controls.spacing
						width: parent.width
						clip: true

						Text {
							text: { if (textInput.text) return `${listView.count} results.`;
								else return `${listView.count} entries.`; }
							color: GlobalVariables.colours.windowText
							font: GlobalVariables.font.smallitalics
						}
					}
				}
			}
		}

		Component.onCompleted: loader.active = false;
	}
}
