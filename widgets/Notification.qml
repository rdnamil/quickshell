/*-----------------------------------
--- Notification widget by andrel ---
-----------------------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import ".."
import "../tools"
import "notification"

SimpleButton { id: root
	property bool unreadNotifs

	darken: false
	animate: false
	onClicked: {
		unreadNotifs = false;
		popout.toggle();
	}
	content: IconImage {
		implicitSize: GlobalConfig.iconSize
		// source: unreadNotifs? Quickshell.iconPath("notification-new") : Quickshell.iconPath("notification")
		source: {
			if (unreadNotifs) {
				if (NotificationService.dnd) {
					return Quickshell.iconPath("notification-disabled-new")
				} else {
					return Quickshell.iconPath("notification-new")
				}
			} else {
				if (NotificationService.dnd) {
					return Quickshell.iconPath("notifications-disabled")
				} else {
					return Quickshell.iconPath("notification")
				}
			}
		}
	}

	PopoutNew { id: popout
		anchor: root
		header: Row {
			padding: GlobalConfig.padding
			spacing: 3

			IconImage {
				anchors.verticalCenter: parent.verticalCenter
				implicitSize: GlobalConfig.iconSize
				source: Quickshell.iconPath("notification-disabled")
			}

			Switch {
				isOn: NotificationService.dnd
				onClicked: NotificationService.dnd = !NotificationService.dnd;
			}
		}
		body: ScrollView {
			height: Math.min(layout.height, 250)

			Column { id: layout
				padding: GlobalConfig.padding
				spacing: GlobalConfig.spacing


				Item {
					width: 256
					height: !NotificationService.list.length > 0? 24 : 0

					Text {
						visible: !NotificationService.list.length > 0
						anchors.centerIn: parent
						text: "No notifications."
						color: GlobalConfig.colour.midground
						font {
							family: GlobalConfig.font.sans
							pointSize: GlobalConfig.font.regular
							weight: GlobalConfig.font.semibold
						}
					}
				}

				Repeater {
					model: NotificationService.server.trackedNotifications
					onItemAdded: if (!popout.isOpen) unreadNotifs = true;

					Column {
						required property var modelData

						width: 256

						Text {
							width: parent.width
							text: `${modelData.appName} ⏵`
							color: GlobalConfig.colour.foreground
							font {
								family: GlobalConfig.font.sans
								pointSize: GlobalConfig.font.small
								weight: GlobalConfig.font.bold
							}

							SimpleButton {
								anchors.right: parent.right
								onAnimCompleted: modelData.dismiss();
								content: IconImage {
									implicitSize: 14
									source: Quickshell.iconPath("dialog-close")
								}
							}
						}

						Text {
							width: parent.width
							text: modelData.summary
							color: GlobalConfig.colour.foreground
							wrapMode: Text.Wrap
							font {
								family: GlobalConfig.font.sans
								pointSize: GlobalConfig.font.regular
							}
						}
					}
				}
			}
		}
	}

	PanelWindow {
		// visible: false
		exclusionMode: ExclusionMode.Ignore
		anchors {
			right: true
			top: true
			bottom: true
		}
		margins.top: GlobalConfig.barHeight
		mask: Region { item: popupLayout }
		width: 256 +60
		color: "transparent"
		// color: "#40ffffff"

		Column { id: popupLayout
			anchors.horizontalCenter: parent.horizontalCenter
			topPadding: GlobalConfig.padding
			spacing: GlobalConfig.spacing
			add: Transition {
				NumberAnimation { property: "x"; from: width; duration: 250; easing.type: Easing.OutCubic }
				NumberAnimation { property: "opacity"; from: 0.0; to: 0.975; easing.type: Easing.OutCubic }
			}

			Repeater {
				model: NotificationService.notificationModel

				Item {
					required property var modelData
					required property int index

					width: notification.width +60
					height: notification.height

					RectangularShadow {
						anchors.fill: notification
						radius: GlobalConfig.cornerRadius
						spread: 0
						blur: 30
						opacity: 0.4
					}

					SimpleButton { id: notification
						anchors.horizontalCenter: parent.horizontalCenter
						// darken: false
						// animate: false
						onClicked: {
							if (modelData.actions.count > 0) {
								NotificationService.list.find(n => n.id === modelData.id).actions[0].invoke();
							} else {
								NotificationService.list.find(n => n.id === modelData.id).dismiss();
							}
							NotificationService.notificationModel.remove(index, 1);
						}
						onMouseEntered: timeoutAnim.pause();
						onMouseExited: timeoutAnim.resume();
						content: Rectangle { id: notifBack
							width: 256
							height: notifLayout.height
							color: GlobalConfig.colour.background
							layer.enabled: true
							layer.effect: OpacityMask {
								maskSource: Rectangle {
									width: notifBack.width
									height: notifBack.height
									radius: GlobalConfig.cornerRadius
								}
							}

							ColumnLayout { id: notifLayout
								spacing: GlobalConfig.spacing

								Item { Layout.fillWidth: true; height: GlobalConfig.spacing; }

								Row {
									leftPadding: GlobalConfig.padding
									rightPadding: GlobalConfig.padding
									spacing: GlobalConfig.spacing

									Image { id: image
										visible: modelData.image || modelData.appIcon !== ""
										width: 52
										height: 52 *(3 /4)
										fillMode: Image.PreserveAspectFit
										source: modelData.image || modelData.appIcon
									}

									Column {
										Text {
											// width: parent.width
											text: `${modelData.appName} ⏵ ${modelData.summary}`
											color: GlobalConfig.colour.foreground
											font {
												family: GlobalConfig.font.sans
												pointSize: GlobalConfig.font.small
												weight: GlobalConfig.font.bold
											}
										}

										Text {
											width: 256 -GlobalConfig.padding *2 -(image.visible? 52 : 0)
											// text: modelData.body
											text: modelData.id
											color: GlobalConfig.colour.foreground
											wrapMode: Text.Wrap
											font {
												family: GlobalConfig.font.sans
												pointSize: GlobalConfig.font.regular
											}
										}
									}
								}

								Item { Layout.fillWidth: true; height: GlobalConfig.spacing; }
							}

							Rectangle {
								height: 3
								color: GlobalConfig.colour.accent

								NumberAnimation on width { id: timeoutAnim
									from: notifBack.width
									to: 0
									duration: 5000
									running: true
									onFinished: NotificationService.notificationModel.remove(index, 1)
								}
							}
						}
					}
				}
			}
		}
	}
}
