/*------------------------------
--- Lockscreen.qml by andrel ---
------------------------------*/

pragma Singleton

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
import qs
import qs.services as Service
import qs.controls as Ctrl
import qs.styles as Style

Singleton { id: root
	function init() {}
	function lock() { lock.locked = true; }

	Service.LockContext { id: lockContext
		onUnlocked: lock.locked = false;
	}

	WlSessionLock { id: lock
		surface: WlSessionLockSurface { id: surface
			color: GlobalVariables.colours.window

			Item { id: lockscreen
				property bool ready

				width: parent.width
				height: parent.height
				onHeightChanged: {
					if (height > 0 && !ready) {
						ready = true;
						y = -height
						lockAnim.restart();
					}
				}

				NumberAnimation { id: lockAnim
					target: lockscreen
					property: "y"
					to: 0
					duration: 300
					easing.type: Easing.OutQuint
				}

				Image { id: background
					anchors.fill: parent
					source: `${Quickshell.env("HOME")}/Pictures/Wallpapers/.current_wall`
					fillMode: Image.PreserveAspectCrop
					layer.enabled: true
					layer.effect: GaussianBlur { samples: 128; }
				}

				ColumnLayout {
					anchors {
						horizontalCenter: parent.horizontalCenter
						top: parent.top
						topMargin: parent.height /2 -label.height
					}
					spacing: 0

					Text { id: label
						Layout.alignment: Qt.AlignHCenter
						text: Qt.formatDateTime(clock.date, "hh:mm")
						color: GlobalVariables.colours.text
						font.family: GlobalVariables.font.sans
						font.pixelSize: screen.height /7.5
						layer.enabled: true
						layer.effect: DropShadow {
							samples: 128
							color: GlobalVariables.colours.shadow
						}

						SystemClock { id: clock
							precision: SystemClock.Seconds
						}
					}

					// password text field
					Row {
						Layout.alignment: Qt.AlignHCenter
						spacing: GlobalVariables.controls.spacing

						Rectangle { id: passwd
							width: screen.width /8
							height: textInput.height
							radius: height /2
							// radius: GlobalVariables.controls.radius
							color: GlobalVariables.colours.base
							opacity: 0.975

							Style.Borders { opacity: 0.4; }

							TextInput { id: textInput
								anchors.centerIn: parent
								width: parent.width -8
								focus: true
								cursorDelegate: Item {}
								font: GlobalVariables.font.monolarge
								horizontalAlignment: Text.AlignHCenter
								color: lockContext.unlockInProgress? GlobalVariables.colours.windowText : GlobalVariables.colours.text
								echoMode: TextInput.Password;
								passwordCharacter: ""
								inputMethodHints: Qt.ImhSensitiveData
								enabled: !lockContext.unlockInProgress
								layer.enabled: true
								layer.effect: OpacityMask {
									maskSource: Rectangle {
										width: textInput.width
										height: textInput.height
										radius: height /2
									}
								}
								onTextChanged: { lockContext.passwd = this.text; lockContext.showFailure = false; }
								onAccepted: lockContext.tryUnlock();
							}

							Connections {
								target: lockContext
								function onFailed() { textInput.clear(); lockContext.showFailure = true; }
							}

							Text {
								anchors.centerIn: parent
								visible: lockContext.showFailure
								text: "Incorrect password"
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.italic
							}
						}

						Ctrl.QsButton { id: btn
							readonly property bool enabled: !lockContext.unlockInProgress && textInput.text

							shade: enabled
							anim: enabled
							onClicked: if (enabled) textInput.accepted();
							content: Rectangle {
								width: icon.width
								height: width
								radius: height /2
								color: GlobalVariables.colours.base
								opacity: 0.975
								layer.enabled: true
								layer.effect: ColorOverlay {
									property color baseColor: GlobalVariables.colours.shadow
									property color semiTransparent: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.5)

									color: btn.enabled? "transparent" : semiTransparent
								}

								Style.Borders { opacity: 0.4; }

								IconImage { id: icon
									implicitSize: 32
									source: Quickshell.iconPath("draw-arrow-forward")
								}
							}
						}
					}
				}

				// for debug purposes
				// Ctrl.QsButton {
				// 	// anchors.centerIn: parent
				// 	onClicked: lockContext.unlocked();
				// 	content: Text { id: quickUnlock
				// 		text: "Unlock me now"
				// 		color: GlobalVariables.colours.text
				// 		font: GlobalVariables.font.regular
				// 	}
				// }
			}
		}
	}

	Process { id: lockProc
		command: ['sh', '-c', `cp "$(swww query | head -n 1 | grep -oP '${Quickshell.env("HOME")}/Pictures/Wallpapers/\\S+(jpg|png|jpeg|webp)')" ${Quickshell.env("HOME")}/Pictures/Wallpapers/.current_wall`]
		stdout: StdioCollector {
			onStreamFinished: lock.locked = true;
		}
	}

	IpcHandler {
		target: "lock"
		function lockScreen(): void { lockProc.running = true; }
	}
}
