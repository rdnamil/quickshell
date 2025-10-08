/*-------------------------------
 * --- MusicPlayer.qml by andrel ---
 * -------------------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import "../"
import "../controls"

Loader { id: root
	readonly property list<MprisPlayer> players: Mpris.players.values
	readonly property MprisPlayer activePlayer: { if (players.length > 0){
		// prefer spotify if it's playing
		for (var player of players) {
			if (player.isPlaying && player.identity.toLowerCase() === "spotify") return player;
		}

		// return any player that is playing
		for (var player of players) {
			if (player.isPlaying) return player;
		}

		// prefer spotify if nothing playing
		for (var player of players) {
			if (player.identity.toLowerCase() === "spotify") return player;
		}

		// fallback to last available player
		return players[players.length - 1];
	} else return null; }

	active: activePlayer
	sourceComponent: RowLayout {
		readonly property real elapsed: activePlayer.position /activePlayer.length

		// format time from total seconds to hours:minutes:seconds
		function formatTime(totalSeconds) {
			var seconds = totalSeconds %60;
			var totalMinutes = Math.floor(totalSeconds /60);
			var hours = Math.floor(totalMinutes /60);
			var minutes = totalMinutes -(hours *60);
			return `${hours >0? (hours +":") : ""}${minutes <10 && hours >0? "0" +minutes : minutes}:${seconds <10? "0" +seconds : seconds}`;
		}

		width: activePlayer.trackTitle? 240 : 0
		spacing: 4
		clip: true

		// update the active player's position while playing
		FrameAnimation {
			running: activePlayer.playbackState == MprisPlaybackState.Playing
			onTriggered: activePlayer.positionChanged()
		}

		// track info; scroll when too long to fit and mouse is hovering over it
		Marquee {
			Layout.preferredHeight: marqueeLayout.height
			Layout.minimumWidth: marqueeLayout.width
			Layout.maximumWidth: 120
			scroll: width < marqueeLayout.width? mouseArea.containsMouse : false
			leftAlign: true
			content: Row { id: marqueeLayout
				spacing: 4

				// track title
				Text {
					anchors.verticalCenter: parent.verticalCenter
					text: activePlayer.trackTitle
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.smallsemibold
				}

				// track artist
				Text {
					anchors.verticalCenter: parent.verticalCenter
					text: activePlayer.trackArtist
					color: GlobalVariables.colours.windowText
					font: GlobalVariables.font.small
				}
			}

			MouseArea { id: mouseArea
				anchors.centerIn: parent
				width: parent.width +4
				height: parent.height +4
				hoverEnabled: true
				acceptedButtons: Qt.AllButtons
				onClicked: (mouse) => {
					switch (mouse.button) {
						case Qt.LeftButton:
							popout.toggle();
							break;
						case Qt.MiddleButton:
							activePlayer.togglePlaying();
							break;
						case Qt.BackButton:
							activePlayer.previous();
							break;
						case Qt.ForwardButton:
							activePlayer.next();
							break;
					}
				}
				onWheel: (wheel) => {	// set player volume on scroll
					var volume = activePlayer.volume;

					volume += (wheel.angleDelta.y /120) *0.05;
					activePlayer.volume = Math.min(Math.max(volume, 0.0), 1.0);

					osd.showOsd();
				}
			}

			Popout { id: popout
				anchor: parent
				header: Column {
					spacing: GlobalVariables.controls.spacing

					Item {
						width: 224
						height: 256
						layer.enabled: true
						layer.effect: OpacityMask {
							maskSource: Item {
								width: 224
								height: 256

								Rectangle {
									anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 12; }
									width: 200
									height: width
									radius: GlobalVariables.controls.radius

									RectangularShadow {
										anchors.fill: parent
										offset.y: 6
										spread: 0
										blur: 30
										radius: parent.radius
										color: "#d0ffffff"
									}
								}
							}
						}

						// blurred album artwork background and glow
						Image {
							anchors.fill: parent
							fillMode: Image.PreserveAspectCrop
							source: activePlayer.trackArtUrl
							layer.enabled: true
							layer.effect: FastBlur { radius: 100; }
						}

						// album artwork
						Image {
							anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 12; }
							width: 200
							height: width
							fillMode: Image.PreserveAspectFit
							source: activePlayer.trackArtUrl
							layer.enabled: true
							layer.effect: OpacityMask {
								maskSource: Rectangle {
									width: 200
									height: width
									radius: GlobalVariables.controls.radius
								}
							}
						}
					}

					Column {
						anchors.horizontalCenter: parent.horizontalCenter
						topPadding: -44
						bottomPadding: GlobalVariables.controls.spacing
						Marquee {
							anchors.horizontalCenter: parent.horizontalCenter
							width: 200
							content: Text {
								text: activePlayer.trackTitle
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.smallsemibold
							}
						}

						Marquee {
							anchors.horizontalCenter: parent.horizontalCenter
							width: 200
							content: Text {
								text: activePlayer.trackArtist || "---"
								color: GlobalVariables.colours.windowText
								font: GlobalVariables.font.smaller
							}
						}
					}
				}
				body: Column {
					anchors.horizontalCenter: parent.horizontalCenter
					topPadding: -GlobalVariables.controls.radius *2 +4

					Rectangle { id: elapsedBar
						width: popout.windowWidth
						height: GlobalVariables.controls.radius *2
						bottomLeftRadius: GlobalVariables.controls.radius
						bottomRightRadius: GlobalVariables.controls.radius
						color: GlobalVariables.colours.accent
						border { color: "#80000000"; width: 1; }
						layer.enabled: true
						layer.effect: OpacityMask {
							maskSource: Item {
								width: elapsedBar.width
								height: elapsedBar.height

								Rectangle {
									anchors.left: parent.left
									width: parent.width *elapsed
									height: parent.height
									gradient: Gradient {
										orientation: Gradient.Horizontal
										GradientStop { position: 0.0; color: "#a0000000" }
										GradientStop { position: 0.9; color: "#a0000000" }
										GradientStop { position: 1.0; color: "#ff000000" }
									}
								}
							}
						}
					}

					RowLayout {
						anchors.horizontalCenter: parent.horizontalCenter
						width: popout.windowWidth -GlobalVariables.controls.spacing
						spacing: 4

						// time elapsed
						Text {
							// anchors.top: parent.top
							Layout.alignment: Qt.AlignTop
							text: formatTime(parseInt(activePlayer.position))
							color: GlobalVariables.colours.windowText
							font: GlobalVariables.font.monosmaller
							// font { family: GlobalVariables.font.mono; pointSize: GlobalVariables.font.smaller; weight: GlobalVariables.font.bold }
						}

						Item { Layout.fillWidth: true; }

						// media control buttons
						// go previous
						QsButton {
							// anchors.verticalCenter: parent.verticalCenter
							Layout.alignment: Qt.AlignVCenter
							onClicked: activePlayer.previous();
							content: IconImage {
								implicitSize: 24
								source: Quickshell.iconPath("media-skip-backward")
							}
						}

						// toggle playing
						QsButton {
							// anchors.verticalCenter: parent.verticalCenter
							Layout.alignment: Qt.AlignVCenter
							onClicked: activePlayer.togglePlaying();
							content: IconImage {
								implicitSize: 40
								source: activePlayer.isPlaying? Quickshell.iconPath("media-playback-pause") : Quickshell.iconPath("media-playback-start")
							}
						}

						// go forward
						QsButton {
							// anchors.verticalCenter: parent.verticalCenter
							Layout.alignment: Qt.AlignVCenter
							onClicked: activePlayer.next();
							content: IconImage {
								implicitSize: 24
								source: Quickshell.iconPath("media-skip-forward")
							}
						}

						Item { Layout.fillWidth: true; }

						// time remaining
						Text {
							// anchors.top: parent.top
							Layout.alignment: Qt.AlignTop
							text: `-${formatTime(parseInt(activePlayer.length -parseInt(activePlayer.position)))}`
							color: GlobalVariables.colours.windowText
							font: GlobalVariables.font.monosmaller
							// font { family: GlobalVariables.font.mono; pointSize: GlobalVariables.font.smaller; weight: GlobalVariables.font.bold }
						}
					}
				}
			}

			Osd { id: osd
				content: RowLayout {
					width: 160
					spacing: GlobalVariables.controls.spacing

					IconImage {
						Layout.margins: GlobalVariables.controls.padding
						Layout.rightMargin: 0
						implicitSize: GlobalVariables.controls.iconSize
						source: Quickshell.iconPath(activePlayer.desktopEntry, true) || Quickshell.iconPath(activePlayer.identity.toLowerCase(), true)
					}

					ProgressBar {
						Layout.margins: GlobalVariables.controls.padding
						Layout.leftMargin: 0
						Layout.fillWidth: true
						height: 12
						progress: activePlayer.volume
					}
				}
			}
		}

		// display the elapsed time of the track as a % of the total track length
		ProgressBar {
			Layout.fillWidth: true
			height: 10
			progress: elapsed
		}
	}
}
