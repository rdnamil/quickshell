import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import qs
import qs.controls
import qs.services as Service
import qs.styles as Style

QsButton { id: root
	anim: false
	shade: false
	onClicked: popout.toggle();
	content: IconImage {
		implicitSize: GlobalVariables.controls.iconSize
		source: Quickshell.iconPath("view-app-grid")
	}

	function reset() {
		categoriesScrollView.ScrollBar.vertical.position = 0.0;
		applicationsScrollView.ScrollBar.vertical.position = 0.0;
		repeater.model = Service.AppDresser.filteredFavourites;
		categoriesLayout.selection = "Favourites";
	}

	Connections {
		target: Service.Popout

		function onKeyPressed(event) { switch (event.key) {
			case Qt.Key_Up:
				if (applicationsLayout.keySelection > 0) applicationsLayout.keySelection--;
				break;
			case Qt.Key_Down:
				if (applicationsLayout.keySelection < (repeater.count -1)) applicationsLayout.keySelection++;
				break;
		}}

		function onAccepted() {
			root.reset();
			repeater.model[applicationsLayout.keySelection].execute();
		}
	}

	Popout { id: popout
		onIsOpenChanged: if (!isOpen) root.reset();
		anchor: root
		header: RowLayout { id: headerContent
			width: screen.width /5

			// user's profile picture and name
			Row {
				Layout.margins: GlobalVariables.controls.padding
				spacing: GlobalVariables.controls.spacing

				IconImage {
					implicitSize: GlobalVariables.controls.iconSize
					source: Quickshell.iconPath("icon_user")
				}

				Text {
					text: Service.AppDresser.usersname
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.regular
				}
			}

			// power options
			Row {
				Layout.alignment: Qt.AlignRight
				Layout.margins: GlobalVariables.controls.padding
				spacing: 3

				// lock screen
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

				// log out
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

				// shut down
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
		body: RowLayout {
			width: screen.width /5
			height: screen.height /3
			spacing: 0

			// categories list
			ScrollView { id: categoriesScrollView
				Layout.preferredWidth: categoriesLayout.width
				Layout.fillHeight: true
				topPadding: GlobalVariables.controls.padding
				bottomPadding: GlobalVariables.controls.padding
				background: Rectangle { color: GlobalVariables.colours.midlight; }

				ColumnLayout { id: categoriesLayout
					property string selection: "Favourites"

					spacing: GlobalVariables.controls.spacing

					Item { Layout.preferredHeight: 1; }

					// Favourites
					QsButton {
						Layout.fillWidth: true
						shade: false
						highlight: true
						fill: categoriesLayout.selection === "Favourites"
						onClicked: {
							categoriesLayout.selection = "Favourites";
							applicationsLayout.keySelection = 0;
							repeater.model = Service.AppDresser.filteredFavourites;
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
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.regular
							}
						}
					}

					// All Apps
					QsButton {
						Layout.fillWidth: true
						shade: false
						highlight: true
						fill: categoriesLayout.selection === "All Applications"
						onClicked: {
							categoriesLayout.selection = "All Applications";
							applicationsLayout.keySelection = 0;
							repeater.model = Service.AppDresser.allApplications;
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
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.regular
							}
						}
					}

					Repeater {
						model: Service.AppDresser.categories
						delegate: QsButton {
							required property var modelData
							required property int index

							Layout.fillWidth: true
							shade: false
							highlight: true
							fill: categoriesLayout.selection === modelData.text[0]
							onClicked: {
								categoriesLayout.selection = modelData.text[0];
								applicationsLayout.keySelection = 0;
								repeater.model = Service.AppDresser.filteredCategories[index];
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
									text: modelData.text[0]
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.regular
								}
							}
						}
					}

					Item { Layout.preferredHeight: 1; }

				}
			}

			Seperator { Layout.fillHeight: true; }

			// applications list
			ColumnLayout {
				Layout.fillWidth: true
				Layout.fillHeight: true
				spacing: 0

				ScrollView { id: applicationsScrollView
					function ensureVisible(item) {
						var flick = applicationsScrollView.contentItem
						var pos = item.mapToItem(flick.contentItem, 0, 0)
						var itemTop = pos.y
						var itemBottom = itemTop + item.height
						var viewTop = flick.contentY
						var viewBottom = flick.contentY + flick.height

						if (itemTop < viewTop) {
							flick.contentY = itemTop -GlobalVariables.controls.spacing
						} else if (itemBottom > viewBottom) {
							flick.contentY = itemBottom - (flick.height -GlobalVariables.controls.spacing)
						}
					}

					Layout.fillWidth: true
					Layout.fillHeight: true

					ColumnLayout { id: applicationsLayout
						property int keySelection: 0

						width: parent.width
						spacing: GlobalVariables.controls.spacing

						Item { Layout.preferredHeight: 1; }

						Repeater { id: repeater
							model: Service.AppDresser.filteredFavourites
							delegate: QsButton { id: application
								required property var modelData
								required property int index

								Layout.fillWidth: true
								shade: false
								highlight: true
								fill: applicationsLayout.keySelection === index
								onIsHighlightedChanged: if (isHighlighted) applicationsLayout.keySelection = index;
								onFillChanged: if (fill) applicationsScrollView.ensureVisible(application);
								onClicked: {
									popout.close();
									modelData.execute();
								}
								content: RowLayout {
									width: parent.width
									spacing: GlobalVariables.controls.spacing

									IconImage {
										Layout.leftMargin: GlobalVariables.controls.padding
										implicitSize: 32
										source: Quickshell.iconPath(modelData.id, true) || Quickshell.iconPath(modelData.icon, "image-missing")
									}

									Column {
										Layout.alignment: Qt.AlignVCenter
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
											font: GlobalVariables.font.small
										}
									}
								}
							}
						}

						Item { Layout.preferredHeight: 1; }
					}
				}

				Item { id: footer
					readonly property TextMetrics textMetric: TextMetrics {
						text: "Placeholder"
						font: GlobalVariables.font.regular
					}

					Layout.fillWidth: true
					Layout.preferredHeight: textMetric.height +(GlobalVariables.controls.padding +GlobalVariables.controls.spacing) *2

					// border
					Rectangle {
						anchors.fill: parent
						color: GlobalVariables.colours.light
						border { color: GlobalVariables.colours.shadow; width: 1; }
					}

					// background
					Rectangle { id: footerBackground
						anchors.bottom: parent.bottom
						width: parent.width
						height: parent.height -2
						color: GlobalVariables.colours.window

						// text field
						Rectangle {
							anchors.centerIn: parent
							width: parent.width -GlobalVariables.controls.padding *2
							height: footer.textMetric.height +GlobalVariables.controls.spacing *2
							radius: GlobalVariables.controls.radius
							color: GlobalVariables.colours.dark
							clip: true

							TextInput {
								anchors {
									left: parent.left
									leftMargin: GlobalVariables.controls.padding
									verticalCenter: parent.verticalCenter
								}
								width: parent.width -GlobalVariables.controls.padding *2
								cursorVisible: text
								cursorPosition: Service.Popout.cursorPosition
								text: Service.Popout.text
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.regular
								onTextChanged: {
									if (text) {
										categoriesScrollView.ScrollBar.vertical.position = 0.0;
										applicationsScrollView.ScrollBar.vertical.position = 0.0;
										applicationsLayout.keySelection = 0;
										categoriesLayout.selection = "";

										repeater.model = DesktopEntries.applications.values
										.map(object => {
											const stxt = text.toLowerCase();
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
									} else {
										repeater.model = Service.AppDresser.allApplications;
										categoriesLayout.selection = "All Applications";
									}
								}

								Text {
									visible: !parent.text
									text: "Start typing to search..."
									color: GlobalVariables.colours.windowText
									font: GlobalVariables.font.italic
									opacity: 0.4
								}
							}

							Style.Borders { opacity: 0.4; }
						}
					}
				}
			}
		}
	}
}
