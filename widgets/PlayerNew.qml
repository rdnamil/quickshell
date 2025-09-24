/*-----------------------------------
--- Music player widget by andrel ---
-----------------------------------*/

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import "root:"
import "root:/tools"

Item { id: root
	readonly property list<MprisPlayer> players: Mpris.players.values
	readonly property MprisPlayer activePlayer: {
		// prefer spotify if it's playing
		for (var i = 0; i <players.length; i++) {
			if (players[i].isPlaying && players[i].identity.toLowerCase() === "spotify")
				return players[i];
		}

		// return any player that is playing
		for (var i = 0; i <players.length; i++) {
			if (players[i].isPlaying)
				return players[i];
		}

		// prefer spotify if nothing playing
		for (var i = 0; i <players.length; i++) {
			if (players[i].identity.toLowerCase() === "spotify")
				return players[i];
		}

		// fallback to last available player
		return players.length >0? players[players.length - 1] : null;
	}
	readonly property real elapsed: activePlayer.position /activePlayer.length

	// format time from total seconds to hours:minutes:seconds
	function formatTime(totalSeconds) {
		var seconds = totalSeconds %60;
		var totalMinutes = Math.floor(totalSeconds /60);
		var hours = Math.floor(totalMinutes /60);
		var minutes = totalMinutes -(hours *60);
		return `${hours >0? (hours +":") : ""}${minutes <10 && hours >0? "0" +minutes : minutes}:${seconds <10? "0" +seconds : seconds}`;
	}

	// update the active player's position while playing
	FrameAnimation {
		running: activePlayer.playbackState == MprisPlaybackState.Playing
		onTriggered: activePlayer.positionChanged()
	}

	width: layout.width
	height: GlobalConfig.barHeight

	Row { id: layout
		anchors.verticalCenter: parent.verticalCenter
		visible: activePlayer
		spacing: 3

		// play/pause button
		SimpleButton {
			content: IconImage {
				implicitSize: GlobalConfig.iconSize
				source: activePlayer.isPlaying? Quickshell.iconPath("media-playback-pause") : Quickshell.iconPath("media-playback-start")
			}
			onClicked: activePlayer.togglePlaying()
		}

		// track title and artist
		SimpleButton { id: trackInfo
			anchors.verticalCenter: parent.verticalCenter
			darken: false
			animate: false
			onClicked: popout.toggle();
			content: Marquee { id: marquee
				width: Math.min(marqueeLayout.width, 125)
				scroll: trackInfo.containsMouse && (marqueeLayout.width >125)
				justify: false
				speed: 50
				content: Row { id: marqueeLayout
					spacing: GlobalConfig.spacing

					Text {
						text: activePlayer.trackTitle
						color: GlobalConfig.colour.foreground
						font { family: GlobalConfig.font.sans; pointSize: GlobalConfig.font.small; weight: GlobalConfig.font.semibold; }
					}
					Text {
						text: activePlayer.trackArtist
						color: GlobalConfig.colour.midground
						font { family: GlobalConfig.font.sans; pointSize: GlobalConfig.font.small; weight: GlobalConfig.font.semibold; }
					}
				}
			}
			layer.enabled: true
			layer.effect: OpacityMask {
				maskSource: Rectangle {
					width: marquee.width
					height: marquee.height
					gradient: Gradient {
						orientation: Gradient.Horizontal
						GradientStop { position: 0.75; color: "#ff000000"; }
						GradientStop { position: 1.0; color: (marquee.width <marqueeLayout.width)? "#00000000" : "#ff000000"; }
					}
				}
			}
		}

		// track time elapsed progress bar
		ProgressBar { id: progressBar
			anchors.verticalCenter: parent.verticalCenter
			width: 100
			height: 8
			fill: elapsed
		}
	}

	// to prevent popout from moving with track length
	Item { id: popoutAnchor
		anchors { left: parent.left; leftMargin: 110; verticalCenter: parent.verticalCenter; }
	}

	PopoutNew { id: popout
		anchor: popoutAnchor
		header: Item {
			width: headerLayout.width
			height: headerLayout.height

			// album art glow
			Item {
				anchors.fill: parent
				layer.enabled: true
				layer.effect: OpacityMask {
					maskSource: Rectangle {
						width: headerLayout.width
						height: headerLayout.height
						color: "transparent"

						RectangularShadow {
							x: headerLayout.width /2 -width /2
							y: headerLayout.height /2 -height /2
							width: albumArt.width
							height: albumArt.height
							radius: GlobalConfig.cornerRadius
							spread: 0
							blur: 30
							color: "#80000000"
						}
					}
				}

				Image {
					anchors.fill: parent
					source: activePlayer.trackArtUrl
					layer.enabled: true
					layer.effect: FastBlur { radius: 100; }
				}
			}

			Column { id: headerLayout
				padding: GlobalConfig.padding
				spacing: 3

				// wrapper for album art
				Rectangle { id: albumArt
					width: 200
					height: 200
					color: GlobalConfig.colour.midground
					layer.enabled: true
					layer.effect: OpacityMask {
						maskSource: Rectangle {
							width: albumArt.width
							height: albumArt.height
							radius: GlobalConfig.cornerRadius /2
							border { width: 1; color: "#a0000000"; }
						}
					}

					// blurred background album art
					Image {
						anchors.centerIn: parent
						width: parent.width
						height: parent.height
						fillMode: Image.PreserveAspectCrop
						source: activePlayer.trackArtUrl
						layer.enabled: true
						layer.effect: FastBlur { radius: 25; }
					}

					// top layer album art
					Image { id: topArt
						visible: source !== ""
						anchors.centerIn: parent
						width: parent.width
						fillMode: Image.PreserveAspectFit
						source: activePlayer.trackArtUrl
						clip: true

						// player icon
						IconImage { id: playerIcon
							anchors { right: parent.right; rightMargin: GlobalConfig.spacing; top: parent.top; topMargin: GlobalConfig.spacing; }
							implicitSize: 16
							source: Quickshell.iconPath(activePlayer.desktopEntry, true)
							layer.enabled: true
							layer.effect: DropShadow {
								radius: 4
								samples: 9
								// spread: 2
								color: "black"
							}
						}
					}
				}

				// track title
				Marquee {
					width: 200
					speed: 50
					content: Text { id: text
						text: activePlayer.trackTitle
						color: GlobalConfig.colour.foreground
						font { family: GlobalConfig.font.sans; pointSize: GlobalConfig.font.small; weight: GlobalConfig.font.semibold; }
					}
				}

				// track artist
				Marquee {
					visible: activePlayer.trackArtist !== ""
					width: 200
					speed: 50
					content: Text {
						text: activePlayer.trackArtist
						color: GlobalConfig.colour.midground
						font { family: GlobalConfig.font.sans; pointSize: GlobalConfig.font.small; weight: GlobalConfig.font.semibold; }
					}
				}
			}
		}
		body: Column {
			topPadding: -GlobalConfig.cornerRadius *2 +1
			spacing: 2

			// bar showing elapsed time
			Rectangle { id: elapsedBar
				width: popout.windowWidth
				height: GlobalConfig.cornerRadius *2
				bottomLeftRadius: GlobalConfig.cornerRadius
				bottomRightRadius: GlobalConfig.cornerRadius
				color: GlobalConfig.colour.accent
				layer.enabled: true
				layer.effect: OpacityMask {
					maskSource: Rectangle {
						width: elapsedBar.width
						height: elapsedBar.height
						color: "transparent"

						Rectangle {
							anchors.left: parent.left
							width: parent.width *elapsed
							height: parent.height
						}
					}
				}
			}

			// track duration/time remaining
			Item {
				anchors.horizontalCenter: parent.horizontalCenter
				width: popout.windowWidth -GlobalConfig.padding *2
				height: trackTimeElapsed.height

				Text { id: trackTimeElapsed
					anchors.left: parent.left
					text: formatTime(parseInt(activePlayer.position))
					color: GlobalConfig.colour.midground
					font { family: GlobalConfig.font.mono; pointSize: GlobalConfig.font.smaller; weight: GlobalConfig.font.bold }
				}

				Text {
					anchors.right: parent.right
					text: "-" +formatTime(parseInt(activePlayer.length -activePlayer.position))
					color: GlobalConfig.colour.midground
					font { family: GlobalConfig.font.mono; pointSize: GlobalConfig.font.smaller; weight: GlobalConfig.font.bold }
				}
			}

			// media control buttons
			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				topPadding: -20

				SimpleButton {
					anchors.verticalCenter: playButton.verticalCenter
					content: IconImage {
						implicitSize: 24
						source: Quickshell.iconPath("media-skip-backward")
					}
					onClicked: activePlayer.previous()
				}

				SimpleButton { id: playButton
					content: IconImage {
						implicitSize: 44
						source: activePlayer.isPlaying? Quickshell.iconPath("media-playback-pause") : Quickshell.iconPath("media-playback-start")
					}
					onClicked: activePlayer.togglePlaying()
				}

				SimpleButton {
					anchors.verticalCenter: playButton.verticalCenter
					content: IconImage {
						implicitSize: 24
						source: Quickshell.iconPath("media-skip-forward")
					}
					onClicked: activePlayer.next()
				}
			}
		}
	}
}
