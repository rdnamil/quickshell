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
import qs.controls as Ctrl
import qs.services as Service
import qs.styles as Style

Singleton { id: root
	readonly property Component content: Item {
		anchors.fill: parent

		SystemClock { id: clock
			precision: SystemClock.Seconds
		}

		ColumnLayout {
			anchors {
				horizontalCenter: parent.horizontalCenter
				top: parent.top
				topMargin: parent.height /2 -(passwd.y +passwd.height /2) // centre on password entry field
			}
			spacing: GlobalVariables.controls.spacing

			// clock
			Text {
				text: Qt.formatDateTime(clock.date, "hh:mm")
				color: GlobalVariables.colours.text
				font.family: "Adwaita Sans Mono"
				font.pixelSize: 192
				layer.enabled: true
				layer.effect: DropShadow {
					samples: 128
					color: GlobalVariables.colours.shadow
				}
			}

			// date & weather
			Row {
				Layout.alignment: Qt.AlignHCenter
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
					color: GlobalVariables.colours.text
					font.family: GlobalVariables.font.sans
					font.pixelSize: 24
				}

				// weather
				Item {
					width: weatherIcon.width
					height: weatherIcon.height

					IconImage { id: weatherIcon
						implicitSize: 30
						source: Quickshell.iconPath(Service.Weather.getWeatherIcon(Service.Weather.weather.current.weather_code, Service.Weather.weather.current.is_day))
						layer.enabled: true
						layer.effect: OpacityMask {
							invert: true
							maskSource: Item {
								width: weatherIcon.width
								height: weatherIcon.height

								Text {
									anchors {
										left: parent.right
										leftMargin: -12
										bottom: parent.bottom
										bottomMargin: -4
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
							leftMargin: -12
							bottom: parent.bottom
							bottomMargin: -4
						}
						text: parseInt(Service.Weather.weather.current.temperature_2m)
						color: GlobalVariables.colours.text
						font.family: GlobalVariables.font.sans
						font.pixelSize: 20
						font.weight: 300

						Text {
							anchors.left: parent.right
							topPadding: 1
							text: Service.Weather.weather.current_units.temperature_2m
							color: GlobalVariables.colours.text
							font: GlobalVariables.font.regular
						}
					}
				}
			}

			// spacer
			Item { Layout.preferredHeight: 48; }

			// password text field
			Row { id: passwd
				Layout.alignment: Qt.AlignHCenter
				spacing: GlobalVariables.controls.spacing

				Rectangle {
					width: 320
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


				}

				Ctrl.QsButton { id: btn
					readonly property bool enabled: !lockContext.unlockInProgress && textInput.text

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

			// spacer
			Item { Layout.preferredHeight: 48; }

			// music player
			RowLayout {
				visible: Service.MusicPlayer.active
				spacing: GlobalVariables.controls.spacing
				clip: false

				Ctrl.QsButton {
					onClicked: Service.MusicPlayer.activePlayer.togglePlaying();
					content: Image { id: coverArt
						height: Math.min(64, sourceSize.height)
						source: Service.MusicPlayer.track.art
						fillMode: Image.PreserveAspectFit
						layer.enabled: true
						layer.effect: OpacityMask {
							maskSource: Rectangle {
								width: coverArt.width
								height: coverArt.height
								radius: GlobalVariables.controls.radius
							}
						}
					}

					IconImage {
						anchors.centerIn: parent
						visible: parent.containsMouse
						implicitSize: 32
						source: Service.MusicPlayer.activePlayer.isPlaying? Quickshell.iconPath("media-playback-pause") : Quickshell.iconPath("media-playback-start")
						layer.enabled: true
						layer.effect: ColorOverlay { color: GlobalVariables.colours.text; }
					}
				}

				ColumnLayout { id: trackInfo
					Layout.alignment: Qt.AlignTop
					spacing: GlobalVariables.controls.spacing /2


					Text { id: nowPlaying
						text: "Now Playing"
						color: Service.MusicPlayer.track.accentColour
						font.family: GlobalVariables.font.sans
						font.pointSize: 10
						font.weight: 600
						font.letterSpacing: 1.2
						layer.enabled: true
						layer.effect: Glow {
							samples: 48
							color: {
								if (nowPlaying.color.hslLightness > 0.5) return Qt.darker(nowPlaying.color, 1.5);
								else return Qt.darker(nowPlaying.color, 0.8);
							}
						}
					}

					Ctrl.Marquee {
						Layout.fillWidth: true
						leftAlign: true
						content: Row {
							spacing: GlobalVariables.controls.spacing /2

							Text {
								text: Service.MusicPlayer.track.title
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.semibold
							}

							Text {
								text: `by ${Service.MusicPlayer.track.artist}`
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.italic
							}
						}
						layer.enabled: true
						layer.effect: DropShadow {
							samples: 48
							color: GlobalVariables.colours.shadow
						}
					}
				}
			}
		}

		// for debug purposes
		// Ctrl.QsButton {
		// 	// anchors.centerIn: parent
		// 	onClicked: lockContext.unlocked();
		// 	content: Text {
		// 		text: "Unlock me now"
		// 		color: GlobalVariables.colours.text
		// 		font: GlobalVariables.font.regular
		// 	}
		// }
	}

	property list<var> wallpaper

	function init() {}
	function lock(transition = true) {
		if (transition) transitionScreens.start();
		else {
			getWallpaper.running = true;
			lock.locked = true;
		}
	}

	Service.LockContext { id: lockContext
		onUnlocked: lock.locked = false;
	}

	WlSessionLock { id: lock
		surface: WlSessionLockSurface { id: surface
			color: GlobalVariables.colours.dark

			Image {
				anchors.fill: parent
				source: root.wallpaper.find(w => w.display === surface.screen.name).path
				fillMode: Image.PreserveAspectCrop
				layer.enabled: true
				layer.effect: GaussianBlur { samples: 128; }
			}

			Loader {
				anchors.fill: parent
				focus: true
				active: parent.visible
				sourceComponent: content
			}
		}
	}

	Variants { id: transitionScreens
		signal start()

		model: Quickshell.screens
		delegate: PanelWindow { id: window
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

			Loader { id: transitionContainer
				anchors.fill: parent
				active: false
				sourceComponent: content
				opacity: 0.0
				transform: Translate { id: transitionTrans; y: -height; }

				Image {
					anchors.fill: parent
					source: root.wallpaper.find(w => w.display === window.modelData.name).path
					fillMode: Image.PreserveAspectCrop
					layer.enabled: true
					layer.effect: GaussianBlur { samples: 128; }
				}
			}

			ParallelAnimation { id: transitionAnim
				property int duration: 250

				onStarted: getWallpaper.running = true;
				onFinished: { lock.locked = true; }

				NumberAnimation {
					target: transitionContainer
					property: "opacity"
					to: 1.0
					duration: transitionAnim.duration
					easing.type: Easing.OutCirc
				}

				NumberAnimation {
					target: transitionTrans
					property: "y"
					to: 0
					duration: transitionAnim.duration
					easing.type: Easing.OutSine
				}
			}

			Connections {
				target: transitionScreens
				function onStart() {
					transitionContainer.active = true;
					transitionAnim.restart();
				}
			}

			Connections {
				target: lockContext
				function onUnlocked() {
					transitionContainer.opacity = 0.0;
					transitionTrans.y = -height;
					transitionContainer.active = false;
				}
			}
		}
	}

	Process { id: getWall
		command: ['sh', '-c', `echo "$(swww query | head -n 1 | grep -oP '${Quickshell.env("HOME")}/Pictures/Wallpapers/\\S+(jpg|png|jpeg|webp)')"`]
		stdout: StdioCollector {
			onStreamFinished: { root.wallpaper = text.trim(); }
		}
	}

	Process { id: getWallpaper
		running: true
		command: ['swww', 'query']
		stdout: StdioCollector {
			onStreamFinished: {
				var ws = text.trim().split('\n');

				root.wallpaper = [];

				for (let w of ws) {
					const parts = w.match(/^:\s*(\S+):\s*([^,]+),\s*scale:\s*(\d+),\s*currently displaying:\s*(\w+):\s*(.+)$/);

					if (!parts) continue;

					root.wallpaper.push({
						display: parts[1],
						resolution: parts[2],
						scale: parts[3],
						type: parts[4],
						path: parts[5]
					});
				}
			}
		}
	}

	IpcHandler {
		target: "lock"
		function lockScreen(transition: bool): void { root.lock(transition); }
	}
}
