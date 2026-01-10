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
import qs.widgets as Widget

Singleton { id: root
	property string currentWallpaper

	function init() {}
	function lock() { lockProc.running = true; }

	Service.LockContext { id: lockContext
		onUnlocked: lock.locked = false;
	}

	Variants { id: placeholder
		signal start()

		model: Quickshell.screens
		delegate: PanelWindow {
			required property var modelData

			screen: modelData
			anchors {
				left: true
				right: true
				top: true
				bottom: true
			}
			WlrLayershell.layer: WlrLayershell.Overlay
			WlrLayershell.exclusiveZone: -1
			mask: Region {}
			// color: "#10ff0000"
			color: "transparent"

			Image { id: background
				y: -height
				width: screen.width
				height: screen.height
				source: root.currentWallpaper
				fillMode: Image.PreserveAspectCrop
				cache: false
				layer.enabled: true
				layer.effect: GaussianBlur { samples: 128; }
			}

			SequentialAnimation { id: placeholderAnim
				NumberAnimation {
					target: background
					property: "y"
					to: 0
					duration: 250
					easing.type: Easing.OutSine
				}

				ScriptAction { script: lock.locked = true; }
			}


			Connections {
				target: placeholder
				function onStart() { placeholderAnim.start(); }
			}

			Connections {
				target: lockContext
				function onUnlocked() { background.y = -height; }
			}
		}
	}

	WlSessionLock { id: lock
		surface: WlSessionLockSurface { id: surface
			color: GlobalVariables.colours.dark

			Item {
				property bool ready

				width: parent.width
				height: parent.height

				Image {
					anchors.fill: parent
					source: root.currentWallpaper
					fillMode: Image.PreserveAspectCrop
					layer.enabled: true
					layer.effect: GaussianBlur { samples: 128; }
				}

				SystemClock { id: clock
					precision: SystemClock.Seconds
				}

				// for debug
				// Rectangle {
				// 	anchors.centerIn: parent
				// 	width: parent.width
				// 	height: 1
    //
				// 	Text {
				// 		text: passwd.y
				// 		color: GlobalVariables.colours.text
				// 		font: GlobalVariables.font.regular
				// 	}
				// }

				Column {
					anchors {
						horizontalCenter: parent.horizontalCenter
						top: parent.top
						topMargin: parent.height /2 -(passwd.y +passwd.height /2) // centre on password entry field
					}
					spacing: GlobalVariables.controls.spacing

					// time
					Text {
						anchors.horizontalCenter: parent.horizontalCenter
						height: 192
						text: Qt.formatDateTime(clock.date, "hh:mm")
						font.family: GlobalVariables.font.sans
						font.pixelSize: 192
						color: GlobalVariables.colours.text
						layer.enabled: true
						layer.effect: DropShadow {
							samples: 128
							color: GlobalVariables.colours.shadow
						}
					}

					// date and weather
					Row {
						anchors.horizontalCenter: parent.horizontalCenter
						spacing: GlobalVariables.controls.spacing *2
						layer.enabled: true
						layer.effect: DropShadow {
							samples: 64
							color: GlobalVariables.colours.shadow
						}

						// date
						Text {
							anchors.verticalCenter: parent.verticalCenter
							text: Qt.formatDateTime(clock.date, "dddd, MMMM d")
							font.family: GlobalVariables.font.sans
							font.pixelSize: 24
							color: GlobalVariables.colours.text
						}

						// weather icon
						Item {
							width: weatherIcon.width
							height: weatherIcon.height

							IconImage { id: weatherIcon
								implicitSize: 32
								source: Quickshell.iconPath(Service.Weather.getWeatherIcon(Service.Weather.weather.current.weather_code, Service.Weather.weather.current.is_day))
								layer.enabled: true
								layer.effect: OpacityMask {
									invert: true
									maskSource: Rectangle {
										width: weatherIcon.width
										height: weatherIcon.height
										color: "transparent"

										Text {
											anchors {
												left: parent.right
												leftMargin: -GlobalVariables.controls.spacing
												bottom: parent.bottom
												bottomMargin: -GlobalVariables.controls.spacing /2
											}
											text: parseInt(Service.Weather.weather.current.temperature_2m)
											font.family: GlobalVariables.font.sans
											font.pixelSize: 20
											font.weight: 300
											layer.enabled: true
											layer.effect: Glow { samples: 8; }
										}
									}
								}
							}

							Text {
								anchors {
									left: parent.right
									leftMargin: -GlobalVariables.controls.spacing
									bottom: parent.bottom
									bottomMargin: -GlobalVariables.controls.spacing /2

								}
								text: parseInt(Service.Weather.weather.current.temperature_2m)
								color: GlobalVariables.colours.text
								font.family: GlobalVariables.font.sans
								font.pixelSize: 20
								font.weight: 300

								Text {
									anchors.left: parent.right
									text: Service.Weather.weather.current_units.temperature_2m
									color: GlobalVariables.colours.text
									topPadding: 1
									font: GlobalVariables.font.regular
								}
							}
						}
					}

					// spacer
					Item { width: 1; height: 48; }

					// password text field
					Rectangle { id: passwd
						anchors.horizontalCenter: parent.horizontalCenter
						width: screen.width /8
						height: textInput.height +GlobalVariables.controls.padding
						// radius: height /2
						radius: GlobalVariables.controls.radius
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
									radius: GlobalVariables.controls.radius
								}
							}
							onTextChanged: { lockContext.passwd = this.text; lockContext.showFailure = false; }
							onAccepted: if (!lockContext.unlockInProgress) lockContext.tryUnlock();
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

						Ctrl.QsButton { id: btn
							readonly property bool enabled: !lockContext.unlockInProgress && textInput.text

							anchors {
								left: parent.right
								leftMargin: GlobalVariables.controls.spacing
							}
							shade: enabled
							anim: enabled
							onClicked: if (enabled) textInput.accepted();
							content: Rectangle {
								width: textInput.height +GlobalVariables.controls.padding
								height: width
								radius: GlobalVariables.controls.radius
								color: GlobalVariables.colours.base
								opacity: 0.975
								layer.enabled: true
								layer.effect: ColorOverlay {
									property color baseColor: GlobalVariables.colours.shadow
									property color semiTransparent: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.5)

									color: btn.enabled? "transparent" : semiTransparent
								}

								Style.Borders { opacity: 0.4; }

								IconImage {
									anchors.centerIn: parent
									implicitSize: parent.height -GlobalVariables.controls.spacing /2
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
		command: ['sh', '-c', `echo "$(swww query | head -n 1 | grep -oP '${Quickshell.env("HOME")}/Pictures/Wallpapers/\\S+(jpg|png|jpeg|webp)')"`]
		stdout: StdioCollector {
			// onStreamFinished: lock.locked = true;
			onStreamFinished: {
				root.currentWallpaper = text.trim();
				placeholder.start();
			}
		}
	}

	IpcHandler {
		target: "lock"
		function lockScreen(): void { if (!lock.locked) root.lock(); }
	}
}
