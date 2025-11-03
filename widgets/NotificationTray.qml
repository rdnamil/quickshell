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

	Connections {
		target: Notifications
		function onAllRead() { root.markAllRead(); }
	}

	Connections {
		target: notificationsModel
		function onValuesChanged() { if (popout.isOpen) Notifications.allRead(); }
	}

	anim: false
	shade: false
	onClicked: popout.toggle();
	onMiddleClicked: Notifications.dnd = !Notifications.dnd;
	tooltip: Text {
		text: `${Notifications.server.trackedNotifications.values.length} Notifications`
		color: GlobalVariables.colours.text
		font: GlobalVariables.font.regular
	}
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
		onIsOpenChanged: {
			if (isOpen) Notifications.allRead();
			else bodyContent.ScrollBar.vertical.position = 0.0;
		}
		anchor: root
		header: RowLayout { id: headerContent
			width: screen.width /6

			// dnd toggle
			Row {
				Layout.margins: GlobalVariables.controls.padding
				spacing: 3

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

			// clear notifications
			QsButton {
				Layout.margins: GlobalVariables.controls.padding
				Layout.alignment: Qt.AlignRight
				onClicked: { while (Notifications.server.trackedNotifications.values.length > 0) {
					Notifications.server.trackedNotifications.values.forEach(n => n.dismiss());
				}}
				tooltip: Text {
					text: "Clear all"
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.regular
				}
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
			topPadding: GlobalVariables.controls.padding
			bottomPadding: GlobalVariables.controls.padding
			width: screen.width /6
			height: Math.min(screen.height /3, layout.height+ topPadding *2)
			ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

			ColumnLayout { id: layout
				spacing: GlobalVariables.controls.spacing
				width: bodyContent.width -bodyContent.effectiveScrollBarWidth

				// top padding element
				Item { Layout.preferredHeight: 1; }

				Repeater { id: notifications
					model: ScriptModel { id: notificationsModel; values: Notifications.server.trackedNotifications.values.slice().reverse(); }
					delegate: QsButton {
						required property var modelData
						required property int index

						// tag notification as unread if notification tray not open
						property bool isRead

						shade: false
						highlight: true
						Layout.fillWidth: true
						onClicked: { // do default notification action or else dismiss on click
							try {
								modelData.actions[0].invoke();
							} catch(err) {
								modelData.dismiss();
							}
						}
						content: RowLayout {
							width: layout.width
							spacing: GlobalVariables.controls.spacing

							// notification image, fallback to app icon if none
							Image { id: image
								visible: modelData.image || modelData.appIcon
								Layout.leftMargin: GlobalVariables.controls.padding
								Layout.preferredWidth: modelData.image? 40 : 24
								Layout.preferredHeight: modelData.image? 40 : 24
								fillMode: Image.PreserveAspectFit
								source: modelData.image || Quickshell.iconPath(modelData.appIcon, true) || modelData.appIcon
							}

							Column {
								Layout.fillWidth: true
								Layout.leftMargin: image.visible? 0 : GlobalVariables.controls.padding
								Layout.rightMargin: GlobalVariables.controls.padding
								topPadding: GlobalVariables.controls.spacing /2
								bottomPadding: GlobalVariables.controls.spacing /2

								// app name and summary
								Text {
									width: parent.width
									text: `<b>${modelData.appName || modelData.desktopEntry} ⏵</b> ${modelData.summary}`
									wrapMode: Text.Wrap
									maximumLineCount: 2
									elide: Text.ElideRight
									color: GlobalVariables.colours.text
									font: GlobalVariables.font.smallsemibold
								}

								// body text
								Text {
									visible: modelData.body
									width: parent.width
									text: modelData.body
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

				// bottom padding element
				Item { Layout.preferredHeight: 1; }
			}
		}
	}
}

