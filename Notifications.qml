/*---------------------------------
--- Notifications.qml by andrel ---
---------------------------------*/

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "services"
import "controls"

PanelWindow { id: root
	property string horizontalPosition

	anchors {
		left: horizontalPosition === "left"
		right: horizontalPosition === "right"
		top: true
		bottom: true
	}
	margins.top: GlobalVariables.controls.barHeight
	exclusionMode: ExclusionMode.Ignore
	WlrLayershell.layer: WlrLayer.Overlay
	mask: Region { item: list; }
	implicitWidth: screen.width /6 +60
	color: "transparent"

	Column { id: list
		topPadding: GlobalVariables.controls.spacing
		spacing: GlobalVariables.controls.spacing
		anchors.horizontalCenter: parent.horizontalCenter
		move: Transition { NumberAnimation { property: "y"; duration: 200; easing.type: Easing.OutCubic; }}

		Repeater {
			model: Notifications.model
			delegate: Item { id: notificationWrapper
				readonly property var match: Notifications.server.trackedNotifications.values.find(n => n.id === model.id)

				property bool expired

				width: notification.width
				height: notification.height
				transform: Translate { id: notificationTranslate; }

				Connections {
					target: Notifications.server.trackedNotifications.values.find(n => n.id === model.id) || null
					function onClosed(reason) { timeoutAnim.complete(); }
				}

				// anim on create or destroy notification
				ParallelAnimation { id: godAnim
					running: true
					onFinished: if (expired) Notifications.model.remove(index, 1);

					NumberAnimation {
						target: notificationTranslate
						property: "y"
						from: expired? 0 : -height
						to: expired? height : 0
						duration: 250
						easing.type: Easing.OutCubic;
					}

					NumberAnimation {
						target: notificationWrapper
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
					blur: 30
					opacity: 0.4
				}

				QsButton { id: notification
					onMouseEntered: timeoutAnim.pause();	// pause expiration timer when mouse hovering over
					onMouseExited: timeoutAnim.resume();
					// do default notification action or else dismiss on click then destroy popup
					onClicked: {
						try {
							notificationWrapper.match.actions[0].invoke();
						} catch(err) {
							notificationWrapper.match.dismiss();
						}
						timeoutAnim.complete();
					}
					content: Rectangle { id: content
						width: screen.width /6
						height: notificationLayout.height
						radius: GlobalVariables.controls.radius
						color: GlobalVariables.colours.mid
						layer.enabled: true
						layer.effect: OpacityMask {
							maskSource: Rectangle {
								width: notification.width
								height: notification.height
								radius: GlobalVariables.controls.radius
							}
						}

						ColumnLayout { id: notificationLayout
							width: parent.width
							spacing: 0

							// expiration timer
							Rectangle {
								Layout.leftMargin: GlobalVariables.controls.radius -3
								width: content.width -GlobalVariables.controls.radius *2 +6
								height: 1
								color: GlobalVariables.colours.accent

								NumberAnimation on width { id: timeoutAnim
									from: width
									to: 0
									duration: model.expireTimeout > 0? model.expireTimeout : 5000
									onFinished: { expired = true; godAnim.start(); } // destroy notification on expiration
								}
							}

							RowLayout {
								Layout.fillWidth: true
								Layout.margins: GlobalVariables.controls.padding
								spacing: GlobalVariables.controls.spacing

								// notification image, fallback to app icon if none
								Image {
									visible: model.image || model.appIcon
									Layout.preferredWidth: model.image? 52 : 24
									Layout.preferredHeight: model.image? 39 : 24
									fillMode: Image.PreserveAspectFit
									source: model.image || Quickshell.iconPath(model.appIcon, true) || model.appIcon
								}

								Column {
									Layout.fillWidth: true

									// app name and summary
									Text {
										width: parent.width
										text: `<b>${model.appName || model.desktopEntry} ⏵</b> ${model.summary}`
										wrapMode: Text.Wrap
										color: GlobalVariables.colours.text
										font: GlobalVariables.font.smallsemibold
									}

									// body text
									Text {
										visible: model.body
										width: parent.width
										text: model.body
										wrapMode: Text.Wrap
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
