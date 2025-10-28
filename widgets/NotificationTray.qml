/*------------------------------------
--- NotificationTray.qml by andrel ---
------------------------------------*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../"
import "../services"
import "../controls"
import "../styles" as Style

QsButton { id: root
	readonly property bool unread: {
		// return false if any notifications in the tray are unread
		for (let n = 0; n < notifications.count; n++) {
			if (!notifications.itemAt(n).isRead) return true;
		} return false;
	}

	function markAllRead() {
		for (let n = 0; n < notifications.count; n++) notifications.itemAt(n).isRead = true;
	}

	anim: false
	shade: false
	onClicked: popout.toggle();
	onMiddleClicked: Notifications.dnd = !Notifications.dnd;
	content: IconImage {
		implicitSize: GlobalVariables.controls.iconSize
		source: {
			if (Notifications.dnd) {
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

	Popout { id: popout
		// tag all notifications in the tray as read when popout opened
		onIsOpenChanged: if (isOpen) Notifications.allRead();
		anchor: root
		header: RowLayout {
			width: bodyContent.width
			spacing: GlobalVariables.controls.spacing

			// do not disturb switch
			Row {
				Layout.margins: GlobalVariables.controls.padding
				spacing: 4

				IconImage {
					anchors.verticalCenter: parent.verticalCenter
					implicitSize: GlobalVariables.controls.iconSize
					source: Quickshell.iconPath("notification-disabled")
				}

				QsSwitch {
					isOn: Notifications.dnd
					onClicked: Notifications.dnd = !isOn;
				}
			}

			// spacer
			Item { Layout.fillWidth: true; }

			// clear all notifications
			QsButton {
				Layout.margins: GlobalVariables.controls.padding
				onClicked: { while (Notifications.server.trackedNotifications.values.length > 0) {
					Notifications.server.trackedNotifications.values.forEach(n => n.dismiss());
				}}
				content: Style.Button {
					IconImage {
						anchors.centerIn: parent
						implicitSize: GlobalVariables.controls.iconSize
						source: Quickshell.iconPath("dialog-close")
					}
				}
			}
		}
		body: ScrollView { id: bodyContent
			height: Math.min(notificationList.height, screen.height /3)
			width: notificationList.width +effectiveScrollBarWidth
			ScrollBar.horizontal.policy: ScrollBar.AlwaysOff


			ColumnLayout { id: notificationList
				width: GlobalVariables.controls.notificationWidth

				// top padding element
				Item { Layout.preferredHeight: 1; }

				Item {
					visible: !(Notifications.server.trackedNotifications.values.length >0)
					Layout.fillWidth: true
					Layout.preferredHeight: 24
					Layout.margins: 2

					Text {
						anchors.centerIn: parent
						text: "Nothing to do."
						color: GlobalVariables.colours.light
						font: GlobalVariables.font.regular
					}
				}

				Repeater { id: notifications
					model: ScriptModel { id: notificationsModel; values: Notifications.server.trackedNotifications.values.slice().reverse(); }
					delegate: QsButton {
						required property var modelData
						required property int index

						// tag notification as unread if notification tray not open
						property bool isRead

						shade: false
						highlight: true
						// do default notification action or else dismiss on click
						onClicked: {
							try {
								modelData.actions[0].invoke();
							} catch(err) {
								modelData.dismiss();
							}
						}
						content: RowLayout { id: bodyLayout
							width: GlobalVariables.controls.notificationWidth
							spacing: GlobalVariables.controls.spacing

							// notification image, fallback to app icon if none
							Image { id: image
								visible: modelData.image || modelData.appIcon
								Layout.leftMargin: GlobalVariables.controls.padding
								Layout.rightMargin: 0
								Layout.preferredWidth: modelData.image? 40 : 24
								Layout.preferredHeight: modelData.image? 40 : 24
								fillMode: Image.PreserveAspectFit
								source: modelData.image || Quickshell.iconPath(modelData.appIcon, true) || modelData.appIcon
							}

							Column {
								Layout.fillWidth: true
								Layout.leftMargin: image.visible? 0 : GlobalVariables.controls.padding
								Layout.rightMargin: GlobalVariables.controls.padding

								// app name and summary
								Text {
									width: parent.width
									text: `<b>${modelData.appName || modelData.desktopEntry} ⏵</b> ${modelData.summary}`
									wrapMode: Text.Wrap
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.smallsemibold
								}

								// body text
								Text {
									visible: modelData.body
									width: parent.width
									text: modelData.body
									wrapMode: Text.Wrap
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.small
								}
							}
						}
					}
				}

				// bottom padding element
				Item { Layout.preferredHeight: 1; }
			}
		}
	}

	Connections {
		target: Notifications
		function onAllRead() { root.markAllRead(); }
	}

	Connections {
		target: notificationsModel
		function onValuesChanged() { if (popout.isOpen) Notifications.allRead(); }
	}
}
