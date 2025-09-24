/*-----------------------------------
--- Music player widget by andrel ---
-----------------------------------*/

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import "root:"
import "root:/tools"
// import "player"

Item { id:root
	readonly property list<MprisPlayer> players: Mpris.players.values
	readonly property MprisPlayer activePlayer: {
		for (var i = 0; i < players.length; i++) {
			if (players[i].isPlaying && players[i].identity === "Spotify")
				return players[i]
		}
		for (var i = 0; i < players.length; i++) {
			if (players[i].isPlaying)
				return players[i]
		}
		return players.length > 0 ? players[players.length - 1] : null
	}

	property int trackLength: 150
	property int scrollSpeed: 45
	property int scrollBarLength: 100
	property int scrollBarHeight: 8
	property int iconSize: GlobalConfig.iconSize
	property int padding: GlobalConfig.spacing
	property string colour: GlobalConfig.colour.foreground
	property string colourMid: GlobalConfig.colour.midground
	property string colourBar: GlobalConfig.colour.accent
	property string fontFamily: GlobalConfig.font.sans
	property int fontSize: GlobalConfig.font.small
	property int fontWeight: GlobalConfig.font.semibold

	implicitWidth: layout.width
	implicitHeight: layout.height

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

	// blurred album art
	Rectangle { id: artMask
		width: root.width
		height: root.height
		color: "transparent"
		layer.enabled: true
		layer.effect: OpacityMask {
			maskSource: Rectangle {
				width: artMask.width
				height: artMask.height
				color: "transparent"

				Rectangle {
					width: parent.width
					height: parent.height
					gradient: Gradient {
						orientation: Gradient.Horizontal
						GradientStop { position: 0.0; color: "#ff000000" }
						GradientStop { position: 0.5; color: "#60000000" }
						GradientStop { position: 1.0; color: "#ff000000" }
					}
				}

				Rectangle {
					width: parent.width
					height: parent.height
					gradient: Gradient {
						orientation: Gradient.Vertical
						GradientStop { position: 0.0; color: "#ff000000" }
						GradientStop { position: 0.4; color: "#00000000" }
						GradientStop { position: 0.6; color: "#00000000" }
						GradientStop { position: 1.0; color: "#ff000000" }
					}
				}

				Rectangle {
					anchors{ right: parent.right; rightMargin: 1; verticalCenter: parent.verticalCenter; }
					width: scrollBarLength -2
					height: scrollBarHeight -2
					radius: height /2
				}
			}
			invert: true
		}
		clip: true

		IconImage {
			// visible: false
			anchors.centerIn: parent
			implicitSize: parent.width
			source: activePlayer.trackArtUrl
			layer.enabled: true
			layer.effect: FastBlur { radius: 25; }
		}
	}

	Row { id: layout
		visible: activePlayer
		spacing: 2

		// play/pause button
		SimpleButton {
			anchors.verticalCenter: parent.verticalCenter
			content: IconImage {
				implicitSize: 16
				source: activePlayer.isPlaying? Quickshell.iconPath("media-playback-pause") : Quickshell.iconPath("media-playback-start")
			}
			onClicked: activePlayer.togglePlaying()
		}

		// display the current track name and artist
		Item { id: currentTrack
			width: (root.trackLength > trackInfo.width) ? trackInfo.width : root.trackLength
			height: GlobalConfig.barHeight

			// clip the track name and artist to user-defined length
			Rectangle { id: infoMask
				anchors.fill: parent
				color: "transparent"
				layer.enabled: true
				layer.effect: OpacityMask {
					maskSource: Rectangle {
						width: infoMask.width
						height: infoMask.height
						gradient: Gradient {
							orientation: Gradient.Horizontal
							GradientStop { position: 0.9; color: "#ff000000" }
							GradientStop { position: 1.0; color: (root.trackLength > trackInfo.width) ? "#ff000000" : "#00000000" }
						}
					}
				}
				clip: true

				Row { id: trackInfo
					anchors.verticalCenter: parent.verticalCenter
					spacing: 2

					Text { id: track
						text: activePlayer.trackTitle
						color: colour
						font { pointSize: fontSize; family: fontFamily; weight: 600; }
					}
					Text { id: seperator
						visible: activePlayer.trackArtist
						text: "•"
						color: colour
						font { pointSize: fontSize; family: fontFamily; }
					}
					Text { id: artist
						text: activePlayer.trackArtist
						color: colourMid
						font { pointSize: fontSize; family: fontFamily; }
					}
					Item { id: spacer; width: 6; height: track.height; }
				}
			}

			// scroll the track info if it's too long to fit
			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				onEntered: {
					if (trackInfo.width > infoMask.width) {
						const distance = trackInfo.width -infoMask.width
						const speed = root.scrollSpeed
						scrollAnim.duration = (distance /speed) *1000
						scrollAnim.from = 0
						scrollAnim.to = infoMask.width -trackInfo.width
						scrollAnim.running = true
					}
				}
				onExited: {
					scrollAnim.running = false
					trackInfo.x = 0
				}
				onClicked: controls.toggle()
			}
			NumberAnimation { id: scrollAnim
				target: trackInfo
				property: "x"
				easing.type: Easing.Linear
			}
		}

		// scroll bar showing elapsed track time
		ProgressBar { id: progressBar
			anchors.verticalCenter: parent.verticalCenter
			width: scrollBarLength
			height: scrollBarHeight
			fill: activePlayer.position /activePlayer.length
		}
	}

	// anchor for popout
	// keeps popout from moving when track title length changes
	Item { id: anchor
		anchors { left: root.left; leftMargin: 140 -(width /2) }
		width: 10
		height: root.height
	}

	// popout music controls
	Popout { id: controls
		anchor: anchor
		content: Item { id: content
			width: contentLayout.width
			height: contentLayout.height

			RectangularShadow {
				anchors.fill: headerBack
				radius: headerBack.radius
				spread: 0
				blur: 30
			}

			Rectangle { id: headerBack
				width: parent.width
				height: parent.height -mediaControls.height
				radius: GlobalConfig.cornerRadius
				color: GlobalConfig.colour.surface
			}

			Rectangle {
				width: parent.width
				height: parent.height
				color: "transparent"
				layer.enabled: true
				layer.effect: OpacityMask {
					maskSource: Rectangle {
						width: contentLayout.width
						height: contentLayout.height
						radius: GlobalConfig.cornerRadius
						border { color: "#c0000000"; width: 1; }
						color: "transparent"

						Rectangle {
							width: parent.width
							height: parent.height
							gradient: Gradient {
								orientation: Gradient.Vertical
								GradientStop { position: 0.0; color: "#80000000" }
								GradientStop { position: 0.9; color: "#ff000000" }
							}
						}
					}
					invert: true
				}
				clip: true

				IconImage {
					anchors.centerIn: parent
					implicitSize: content.height
					source: topArt.source
					layer.enabled: true
					layer.effect: FastBlur { radius: 100; }
				}
			}

			Column { id: contentLayout
				leftPadding: 15
				rightPadding: 15
				topPadding: 10
				// bottomPadding: 10
				// spacing: 6

				Rectangle { id: contentArt
					width: 200
					height: width
					color: "transparent"
					layer.enabled: true
					layer.effect: OpacityMask {
						maskSource: Rectangle {
							width: contentArt.width
							height: contentArt.height
							radius: 4
						}
					}

					// placeholder album art
					Image {
						width: 200
						height: width
						source: "player/placeholder"
						opacity: 0.5
					}

					// blurred album art; visible if album art isn't 1:1 proportions
					Image {
						width: 200
						height: width
						fillMode: Image.PreserveAspectCrop
						source: topArt.source
						layer.enabled: true
						layer.effect: FastBlur { radius: 25; }
					}

					RectangularShadow {
						anchors.fill: topArt
						spread: 0
						blur: 30
					}

					// album art
					Image { id: topArt
						anchors.centerIn: parent
						width: 200
						fillMode: Image.PreserveAspectFit
						source: activePlayer.trackArtUrl
					}
				}


				Column { id: contentInfo
					anchors.horizontalCenter: parent.horizontalCenter
					topPadding: 6
					bottomPadding: 6
					spacing: 2

					Text {
						anchors.horizontalCenter: parent.horizontalCenter
						width: contentArt.width
						wrapMode: Text.WordWrap
						horizontalAlignment: Text.AlignHCenter
						text: activePlayer.trackTitle
						color: colour
						font { pointSize: fontSize; family: fontFamily; weight: 600; }
					}

					Text {
						anchors.horizontalCenter: parent.horizontalCenter
						text: activePlayer.trackArtist
						color: colourMid
						font { pointSize: fontSize; family: fontFamily; }
					}

					Text {
						anchors.horizontalCenter: parent.horizontalCenter
						text: formatTime(parseInt(activePlayer.position)) +" / " +formatTime(parseInt(activePlayer.length))
						color: colourMid
						font { pointSize: fontSize -2; family: GlobalConfig.font.mono; }
					}
				}

				Row { id: mediaControls
					topPadding: -3
					anchors.horizontalCenter: parent.horizontalCenter
					spacing: 0

					SimpleButton {
						anchors.verticalCenter: parent.verticalCenter
						content: IconImage {
							implicitSize: 24
							source: Quickshell.iconPath("media-skip-backward")
						}
						onClicked: activePlayer.previous()
					}

					SimpleButton {
						content: IconImage {
							implicitSize: 44
							source: activePlayer.isPlaying? Quickshell.iconPath("media-playback-pause") : Quickshell.iconPath("media-playback-start")
						}
						onClicked: activePlayer.togglePlaying()
					}

					SimpleButton {
						anchors.verticalCenter: parent.verticalCenter
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
}
