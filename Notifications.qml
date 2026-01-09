/*----------------------------------------------
--- Notifications.qml - quickshell by andrel ---
----------------------------------------------*/

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.services as Service
import qs.controls as Ctrl

Singleton { id: root
	function init() {}

	Connections {
		target: Service.Notifications.model
		function onCountChanged() {
			if (loader.active && !(Service.Notifications.model.count > 0)) {
				loader.active = false;
				console.log(`Notifications: active = ${loader.active}`);
			} else if (!loader.active && (Service.Notifications.model.count > 0)) {
				loader.active = true;
				console.log(`Notifications: active = ${loader.active}`);
			}
		}
	}

	Loader { id: loader
		sourceComponent: PanelWindow {
			anchors.top: true
			exclusiveZone: 0
			WlrLayershell.layer: WlrLayer.Top
			WlrLayershell.namespace: "qs:notifications"
			mask: Region { item: list; }
			implicitWidth: screen.width /6 +60
			implicitHeight: repeater.count > 0? list.height +15 : 0
			// color: "#10ff0000"
			color: "transparent"

			Column { id: list
				topPadding: GlobalVariables.controls.spacing /2
				spacing: GlobalVariables.controls.spacing
				anchors.horizontalCenter: parent.horizontalCenter
				move: Transition { NumberAnimation { property: "y"; duration: 200; easing.type: Easing.OutCubic; }}

				Repeater { id: repeater
					model: Service.Notifications.model
					delegate: Item { id: notifWrapper
						required property var model
						required property int index

						readonly property var match: Service.Notifications.server.trackedNotifications.values.find(n => n.id === model.id)

						property bool expired

						width: screen.width /6
						height: notification.height
						transform: Translate { id: notifTranslate; }

						Connections {
							target: Service.Notifications.server.trackedNotifications.values.find(n => n.id === model.id) || null
							function onClosed(reason) { timeoutAnim.complete(); }
						}

						// anim on create or destroy notification
						ParallelAnimation { id: godAnim
							running: true
							onFinished: if (expired) Service.Notifications.model.remove(index, 1);

							NumberAnimation {
								target: notifTranslate
								property: "y"
								from: expired? 0 : -height
								to: expired? -height : 0
								duration: 250
								easing.type: Easing.OutCubic;
							}

							NumberAnimation {
								target: notifWrapper
								property: "opacity"
								from: expired? 0.975 : 0.0
								to: expired? 0.0 : 0.975
								duration: 250
								easing.type: Easing.OutCubic
							}
						}

						RectangularShadow {
							anchors.fill: notification
							radius: GlobalVariables.controls.radius
							spread: 0
							blur: 10
							color: GlobalVariables.colours.shadow
							opacity: 0.6
						}

						Ctrl.QsButton { id: notification
							onMouseEntered: timeoutAnim.pause();	// pause expiration timer when mouse hovering over
							onMouseExited: timeoutAnim.resume();
							// do default notification action or else dismiss on click then destroy popup
							onClicked: {
								try {
									notifWrapper.match.actions[0].invoke();
								} catch(err) {
									notifWrapper.match.dismiss();
								}
								timeoutAnim.complete();
							}
							content: Rectangle { id: content
								width: screen.width /6
								height: notifLayout.height
								layer.enabled: true
								layer.effect: OpacityMask {
									maskSource: Rectangle {
										width: content.width
										height: content.height
										radius: GlobalVariables.controls.radius
									}
								}
								color: GlobalVariables.colours.mid

								// expiration timer
								Rectangle {
									width: parent.width
									height: 3
									color: GlobalVariables.colours.accent

									NumberAnimation on width { id: timeoutAnim
										from: width
										to: 0
										duration: model.expireTimeout > 0? model.expireTimeout : 5000
										onFinished: { expired = true; godAnim.start(); } // destroy notification on expiration
									}
								}

								Column { id: notifLayout
									spacing: GlobalVariables.controls.spacing
									topPadding: GlobalVariables.controls.spacing
									bottomPadding: GlobalVariables.controls.spacing
									width: parent.width

									RowLayout {
										width: parent.width
										spacing: GlobalVariables.controls.spacing

										// notification image, fallback to app icon if none
										Image { id: image
											visible: model.image
											Layout.leftMargin: GlobalVariables.controls.padding
											Layout.preferredWidth: 40
											Layout.preferredHeight: 40
											fillMode: Image.PreserveAspectFit
											source: model.image
										}

										Column {
											Layout.fillWidth: true
											Layout.leftMargin: image.visible? 0 : GlobalVariables.controls.padding
											Layout.rightMargin: GlobalVariables.controls.padding
											topPadding: GlobalVariables.controls.spacing /4
											bottomPadding: GlobalVariables.controls.spacing /4
											spacing: 3

											RowLayout {
												width: parent.width

												IconImage {
													visible: Quickshell.iconPath(model.appIcon, true) || model.appIcon
													implicitSize: GlobalVariables.controls.iconSize
													source: Quickshell.iconPath(model.appIcon, true) || model.appIcon
												}

												// app name and summary
												Text {
													Layout.fillWidth: true
													text: `<b>${model.appName || model.desktopEntry} ⏵</b> ${model.summary}`
													elide: Text.ElideRight
													color: GlobalVariables.colours.text
													font: GlobalVariables.font.smallsemibold
												}
											}

											// body text
											Text {
												visible: model.body
												width: parent.width
												text: model.body
												wrapMode: Text.Wrap
												maximumLineCount: 2
												elide: Text.ElideRight
												color: GlobalVariables.colours.text
												font: GlobalVariables.font.small
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
