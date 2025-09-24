/*-----------------------------------
--- Notification widget by andrel ---
-----------------------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../"
import "../tools"
import "notification"

SimpleButton { id: root
	readonly property bool unread: {
		// return false if any notifications in the tray are unread
		for (let n = 0; n < trayNotifications.count; n++) {
			if (!trayNotifications.itemAt(n).isRead) return true;
		} return false;
	}

	darken: false
	animate: false
	onClicked: popout.toggle();
	content: IconImage {
		implicitSize: GlobalConfig.iconSize
		source: {
			if (NotificationService.dnd) {
				if (unread) {
					return Quickshell.iconPath("notification-disabled-new")
				} else {
					return Quickshell.iconPath("notifications-disabled")
				}
			} else {
				if (unread) {
					Quickshell.iconPath("notification-new")
				} else {
					Quickshell.iconPath("notification")
				}
			}
		}
	}

	// notification history tray
	PopoutNew { id: popout
		onIsOpenChanged: {
			// tag all notifications in the tray as read
			if (isOpen) for (let n = 0; n < trayNotifications.count; n++) {
				trayNotifications.itemAt(n).isRead = true;
			}
		}
		anchor: root
		header: RowLayout {
			spacing: GlobalConfig.spacing
			width: bodyContent.width

			// do not disturb switch
			Row {
				Layout.margins: GlobalConfig.padding
				spacing: 3

				IconImage {
					anchors.verticalCenter: parent.verticalCenter
					implicitSize: GlobalConfig.iconSize
					source: Quickshell.iconPath("notification-disabled")
				}

				Switch {
					isOn: NotificationService.dnd
					onClicked: NotificationService.dnd = !isOn;
				}
			}

			// spacer
			Item { Layout.fillWidth: true; }

			// clear all button
			SimpleButton {
				Layout.margins: GlobalConfig.padding
				onClicked: {
					while (NotificationService.server.trackedNotifications.values.length > 0) {
						NotificationService.server.trackedNotifications.values.forEach(n => n.dismiss());
					}
				}
				content: IconImage {
					implicitSize: GlobalConfig.iconSize
					source: Quickshell.iconPath("close-dialog")
				}
			}
		}
		body: ScrollView { id: bodyContent
			height: Math.min(trayList.height, 256)
			width: trayList.width +effectiveScrollBarWidth
			ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

			ColumnLayout { id: trayList
				spacing: GlobalConfig.spacing
				width: GlobalConfig.notificationWidth

				// top padding element
				Item { Layout.fillWidth: true; }

				Text {
					visible: !NotificationService.server.trackedNotifications.values.length > 0
					anchors.horizontalCenter: parent.horizontalCenter
					text: "No notifications are found."
					color: GlobalConfig.colour.midground
					font {
						family: GlobalConfig.font.sans
						pointSize: GlobalConfig.font.regular
					}
				}

				Repeater { id: trayNotifications
					model: NotificationService.server.trackedNotifications

					SimpleButton {
						required property var modelData

						// tag notification as unread if notification tray not open
						property bool isRead: popout.isOpen

						// do default notification action or else dismiss on click
						onClicked: {
							try {
								modelData.actions[0].invoke();
							} catch(err) {
								modelData.dismiss();
							}
						}
						Layout.fillWidth: true
						drawBackground: true
						content: RowLayout {
							width: GlobalConfig.notificationWidth
							spacing: GlobalConfig.spacing

							// left padding element
							Item { width: GlobalConfig.padding; }

							// notification image, fallback to app icon if none
							Image {
								visible: modelData.image || modelData.appIcon
								Layout.preferredWidth: modelData.image? 52 : 24
								Layout.preferredHeight: modelData.image? 39 : 24
								fillMode: Image.PreserveAspectFit
								source: modelData.image || Quickshell.iconPath(modelData.appIcon, true) || modelData.appIcon
							}

							Column {
								Layout.fillWidth: true

								// app name and summary text
								Text {
									text: `${modelData.appName || model.desktopEntry} ⏵ ${modelData.summary}`
									color: GlobalConfig.colour.foreground
									font {
										family: GlobalConfig.font.family
										pointSize: GlobalConfig.font.small
										weight: GlobalConfig.font.bold
									}
								}

								// body text
								Text {
									width: parent.width
									text: modelData.body
									color: GlobalConfig.colour.foreground
									wrapMode: Text.Wrap
									font {
										family: GlobalConfig.font.family
										pointSize: GlobalConfig.font.small
									}
								}
							}

							// right padding element
							Item { width: GlobalConfig.padding; }
						}
					}
				}

				// bottom padding element
				Item { Layout.fillWidth: true; }
			}
		}
	}

	// notification on screen popup
	PanelWindow {
		visible: !NotificationService.dnd
		exclusionMode: ExclusionMode.Ignore
		WlrLayershell.layer: WlrLayer.Overlay
		anchors {
			right: true
			top: true
			bottom: true
		}
		margins.top: GlobalConfig.barHeight
		mask: Region { item: ospList; }
		width: GlobalConfig.notificationWidth +60
		color: "transparent"

		Column { id: ospList
			topPadding: GlobalConfig.spacing
			spacing: GlobalConfig.spacing
			anchors.horizontalCenter: parent.horizontalCenter
			move: Transition { NumberAnimation { property: "y"; duration: 200; easing.type: Easing.OutCubic; }}

			Repeater {
				model: NotificationService.model

				Item { id: notification
					readonly property var match: NotificationService.server.trackedNotifications.values.find(n => n.id === model.id)

					property bool expired

					width: ospNotification.width
					height: ospNotification.height
					transform: Translate { id: notificationTranslate; }

					// anim on create or destroy notification
					ParallelAnimation { id: godAnim
						running: true
						onFinished: if (expired) NotificationService.model.remove(index, 1);

						NumberAnimation {
							target: notificationTranslate
							property: "y"
							from: expired? 0 : -height
							to: expired? height : 0
							duration: 250
							easing.type: Easing.OutCubic
						}

						NumberAnimation {
							target: notification
							property: "opacity"
							from: expired? 0.975 : 0.0
							to: expired? 0.0 : 0.975
							duration: 250
							easing.type: Easing.OutCubic
						}
					}

					RectangularShadow {
						anchors.fill: ospNotification
						radius: GlobalConfig.cornerRadius
						spread: 0
						blur: 30
						opacity: 0.4
					}

					SimpleButton { id: ospNotification
						onMouseEntered: timeoutAnim.pause();	// pause expiration timer when mouse hovering over
						onMouseExited: timeoutAnim.resume();

						// do default notification action or else dismiss on click then destroy popup
						onClicked: {
							try {
								notification.match.actions[0].invoke();
							} catch(err) {
								notification.match.dismiss();
							}
							timeoutAnim.complete();
						}
						content: Item {
							width: GlobalConfig.notificationWidth
							height: ospLayout.height
							layer.enabled: true
							layer.effect: OpacityMask {
								maskSource: Rectangle {
									width: notification.width
									height: notification.height
									radius: GlobalConfig.cornerRadius
								}
							}

							Rectangle {
								anchors.fill: parent
								color: GlobalConfig.colour.background
							}

							ColumnLayout { id: ospLayout
								width: parent.width
								spacing: 0

								// expiration timer
								Rectangle {
									Layout.fillWidth: true
									height: 3
									color: GlobalConfig.colour.accent

									NumberAnimation on width { id: timeoutAnim
										from: width
										to: 0
										duration: model.expireTimeout > 0? model.expireTimeout : 5000
										onFinished: { expired = true; godAnim.start(); } // destroy notification on expiration
									}
								}

								// top padding element
								Item { Layout.fillWidth: true; height: GlobalConfig.padding; }

								RowLayout {
									Layout.fillWidth: true
									Layout.leftMargin: GlobalConfig.padding
									Layout.rightMargin: GlobalConfig.padding
									spacing: GlobalConfig.spacing

									// notification image, fallback to app icon if none
									Image {
										visible: model.image || model.appIcon
										Layout.preferredWidth: model.image? 52 : 24
										Layout.preferredHeight: model.image? 39 : 24
										fillMode: Image.PreserveAspectFit
										source: model.image || Quickshell.iconPath(model.appIcon, true) || model.appIcon
									}

									// notification text
									Column {
										Layout.fillWidth: true

										// app name and summary text
										Text {
											text: `${model.appName || model.desktopEntry} ⏵ ${model.summary}`
											color: GlobalConfig.colour.foreground
											font {
												family: GlobalConfig.font.family
												pointSize: GlobalConfig.font.small
												weight: GlobalConfig.font.bold
											}
										}

										// body text
										Text {
											width: parent.width
											text: model.body
											color: GlobalConfig.colour.foreground
											wrapMode: Text.Wrap
											font {
												family: GlobalConfig.font.family
												pointSize: GlobalConfig.font.small
											}
										}
									}
								}

								// bottom padding element
								Item { Layout.fillWidth: true; height: GlobalConfig.padding; }
							}
						}
					}
				}
			}
		}
	}
}
