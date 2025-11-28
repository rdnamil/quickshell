/*-------------------------------
--- MusicPlayer.qml by andrel ---
-------------------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs
import qs.controls
import qs.styles as Style

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

	property int minBarWidth: 100
	// store track current data
	property var track: QtObject {
		property string title: {
			var trackTitle = activePlayer.trackTitle;
			return trackTitle
		}
		property string artist: {
			var trackArtist = activePlayer.trackArtist;
			return trackArtist
		}
		property string art: activePlayer.trackArtUrl;
		property ColorQuantizer colorQuantizer: ColorQuantizer {
			source: root.track.art
			depth: 4
			rescaleSize: 64
		}
	}

	// format time from total seconds to hours:minutes:seconds
	function formatTime(totalSeconds) {
		var seconds = totalSeconds %60;
		var totalMinutes = Math.floor(totalSeconds /60);
		var hours = Math.floor(totalMinutes /60);
		var minutes = totalMinutes -(hours *60);
		return `${hours >0? (hours +":") : ""}${minutes <10 && hours >0? "0" +minutes : minutes}:${seconds <10? "0" +seconds : seconds}`;
	}

	// update track title and artist only when ready
	Connections {
		target: activePlayer
		function onTrackTitleChanged() { if (activePlayer.trackTitle) {
			// prevent widget from unloading
			grace.stop();
			root.active = true;

			// update track title
			var trackTitle = activePlayer.trackTitle;
			track.title = trackTitle;
		} else grace.restart(); /*restart timer to unload widget*/ }

		function onTrackArtistChanged() { if (activePlayer.trackArtist) {
			// update track artist
			var trackArtist = activePlayer.trackArtist;
			track.artist = trackArtist;
		}}
	}

	// unload widget after inactivity
	Timer { id: grace
		interval: 1000
		onTriggered: parent.active = false;
	}

	onActivePlayerChanged: { if (activePlayer) {
			// prevent widget from unloading
			grace.stop();
			root.active = true;

			// update track title and artist
			var trackArtist = activePlayer.trackArtist;
			var trackTitle = activePlayer.trackTitle;
			track.title = trackTitle;
			track.artist = trackArtist;
		} else { grace.restart(); /*restart timer to unload widget*/ }}
	active: false
	width: active? screen.width /8 : 0
	sourceComponent: RowLayout {
		width: screen.width /8

		// update the active player's position while playing
		FrameAnimation {
			running: activePlayer.playbackState == MprisPlaybackState.Playing
			onTriggered: activePlayer.positionChanged()
		}

		// track info; scroll when too long to fit and mouse is hovering over it
		Marquee {
			Layout.preferredWidth: marqueeLayout.width
			Layout.maximumWidth: parent.width -minBarWidth
			scroll: width < marqueeLayout.width? mouseArea.containsMouse : false
			leftAlign: true
			content: Row { id: marqueeLayout
				spacing: 3

				// track title
				Text {
					anchors.verticalCenter: parent.verticalCenter
					text: track.title || activePlayer.trackTitle
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.smallsemibold
				}

				// track artist
				Text {
					anchors.verticalCenter: parent.verticalCenter
					text: track.artist || activePlayer.trackArtist
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
		}

		// display the elapsed time of the track as a % of the total track length
		Style.Slider {
			Layout.fillWidth: true
			wheelEnabled: activePlayer.positionSupported
			leftPadding: 0
			rightPadding: 0
			from: 0.0
			value: activePlayer.position
			to: activePlayer.length
			onMoved: activePlayer.position = value;
			stepSize: 1
			tooltipContent: Text {
				readonly property TextMetrics textMetrics: TextMetrics {
					text: formatTime(parseInt(activePlayer.length))
					font: GlobalVariables.font.monosmaller
				}

				width: textMetrics.width
				height: textMetrics.height
				text: formatTime(parseInt(activePlayer.position))
				color: GlobalVariables.colours.text
				font: GlobalVariables.font.monosmaller
				horizontalAlignment: Text.AlignHCenter
			}
		}
	}

	Popout { id: popout
		anchor: root
		header: Item { id: headerContent
			width: screen.width /10
			height: width + headerLayout.height  +controls.height +GlobalVariables.controls.padding *2

			Rectangle { id: controls
				anchors {
					horizontalCenter: parent.horizontalCenter
					top: parent.top
					topMargin: GlobalVariables.controls.padding
				}
				width: parent.width -GlobalVariables.controls.padding *2
				height: controlsLayout.height +GlobalVariables.controls.padding *2
				radius: GlobalVariables.controls.radius
				color: GlobalVariables.colours.dark

				Style.Borders { opacity: 0.6; }

				RowLayout { id: controlsLayout
					readonly property real buttonSize: 20

					anchors.verticalCenter: parent.verticalCenter
					width: parent.width
					spacing: GlobalVariables.controls.spacing

					// shuffle playlist
					QsButton {
						Layout.fillWidth: true
						shade: activePlayer.shuffleSupported
						anim: activePlayer.shuffleSupported
						tooltip: Text {
							text: "Shuffle"
							color: GlobalVariables.colours.text
							font: GlobalVariables.font.regular
						}
						onClicked: if (activePlayer.shuffleSupported) activePlayer.shuffle = !activePlayer.shuffle;
						content: IconImage {
							anchors.centerIn: parent
							implicitSize: controlsLayout.buttonSize
							source: {
								if (activePlayer.shuffle) return Quickshell.iconPath("media-playlist-shuffle");
								else return Quickshell.iconPath("media-playlist-no-shuffle");
							}
						}
					}

					// go previous
					QsButton {
						Layout.fillWidth: true
						tooltip: Text {
							text: "Previous"
							color: GlobalVariables.colours.text
							font: GlobalVariables.font.regular
						}
						onClicked: activePlayer.previous();
						content: IconImage {
							anchors.centerIn: parent
							implicitSize: controlsLayout.buttonSize
							source: Quickshell.iconPath("media-skip-backward")
						}
					}

					// toggle playing
					QsButton {
						Layout.fillWidth: true
						onClicked: activePlayer.togglePlaying();
						tooltip: Text {
							text: activePlayer.isPlaying? "Pause" : "Play"
							color: GlobalVariables.colours.text
							font: GlobalVariables.font.regular
						}
						content: IconImage {
							anchors.centerIn: parent
							implicitSize: controlsLayout.buttonSize
							source: activePlayer.isPlaying? Quickshell.iconPath("media-playback-pause") : Quickshell.iconPath("media-playback-start")
						}
					}

					// go forward
					QsButton {
						Layout.fillWidth: true
						tooltip: Text {
							text: "Skip"
							color: GlobalVariables.colours.text
							font: GlobalVariables.font.regular
						}
						onClicked: activePlayer.next();
						content: IconImage {
							anchors.centerIn: parent
							implicitSize: controlsLayout.buttonSize
							source: Quickshell.iconPath("media-skip-forward")
						}
					}

					// shuffle playlist
					QsButton {
						Layout.fillWidth: true
						shade: activePlayer.loopSupported
						anim: activePlayer.loopSupported
						tooltip: Text {
							text: switch (activePlayer.loopState) {
								case MprisLoopState.Playlist:
									return "Loop track";
								case MprisLoopState.Track:
									return "Disable loop";
								default:
									return "Loop album";
							}
							color: GlobalVariables.colours.text
							font: GlobalVariables.font.regular
						}
						onClicked: if (activePlayer.loopSupported) switch (activePlayer.loopState) {
								case MprisLoopState.Playlist:
									activePlayer.loopState = MprisLoopState.Track;
								case MprisLoopState.Track:
									activePlayer.loopState = MprisLoopState.None;
								case MprisLoopState.None:
									activePlayer.loopState = MprisLoopState.Playlist;
						}
						content: IconImage {
							anchors.centerIn: parent
							implicitSize: controlsLayout.buttonSize
							source: switch (activePlayer.loopState) {
								case MprisLoopState.Playlist:
									return Quickshell.iconPath("media-playlist-repeat", "media-playlist-repeat-symbolic");
								case MprisLoopState.Track:
									return Quickshell.iconPath("media-playlist-repeat-song", "media-playlist-repeat-song-symbolic");
								default:
									return Quickshell.iconPath("media-playlist-no-repeat", "media-playlist-no-repeat-symbolic");
							}
						}
					}
				}
			}

			// album art wrapper
			Item { id: artWrapper
				anchors.fill: parent
				layer.enabled: true
				layer.effect: OpacityMask {
					maskSource: Item {
						width: headerContent.width
						height: headerContent.height

						RectangularShadow {
							anchors.fill: trackArtMask
							radius: trackArtMask.radius
							offset.y: 10
							spread: 3
							blur: 32
						}

						Rectangle { id: trackArtMask
							anchors {
								horizontalCenter: parent.horizontalCenter
								top: parent.top
								topMargin: GlobalVariables.controls.padding *2 +controls.height +1
							}
							width: parent.width -GlobalVariables.controls.padding *2 -2
							height: width
							radius: GlobalVariables.controls.radius
						}
					}
				}

				// placeholder fill
				Rectangle {
					anchors.fill: parent
					color: GlobalVariables.colours.light
				}

				// blurred album art
				Image {
					anchors.fill: parent
					fillMode: Image.PreserveAspectCrop
					source: root.track.art
					layer.enabled: true
					layer.effect: FastBlur { radius: 100; }
				}

				// background color
				Rectangle {
					// visible: false
					anchors.fill: parent
					color: Array.from(root.track.colorQuantizer.colors).sort((a, b) => {
						const satWeight = 0.5
						const satTarget = 0.0025
						const valueTarget = 0.0025

						const a_satNormal = 1 /(1 +Math.abs(a.hsvSaturation /256 -satTarget));
						const b_satNormal = 1 /(1 +Math.abs(b.hsvSaturation /256 -satTarget));
						const a_valueNormal = 1 /(1 +Math.abs(a.hsvValue /256 -valueTarget));
						const b_valueNormal = 1 /(1 +Math.abs(b.hsvValue /256 -valueTarget));

						const a_score = satWeight *a_satNormal +(1 -satWeight) *a_valueNormal
						const b_score = satWeight *b_satNormal +(1 -satWeight) *b_valueNormal

						return b_score -a_score;
					})[0]
					opacity: 0.5
				}

				RectangularShadow {
					anchors.fill: parent
					offset.y: 10
					// offset.x: 10
					spread: 10
					blur: 32
					color: GlobalVariables.colours.shadow
					opacity: 0.725
					layer.enabled: true
					layer.effect: OpacityMask {
						invert: true
						maskSource: Item {
							width: artWrapper.width
							height: artWrapper.height

							Rectangle {
								anchors {
									horizontalCenter: parent.horizontalCenter
									top: parent.top
									topMargin: (controls.height +GlobalVariables.controls.padding *2) +1
								}
								width: (parent.width -GlobalVariables.controls.padding *2) -2
								height: width
								radius: GlobalVariables.controls.radius
							}
						}
					}
				}

				// album art
				Item {
					anchors {
						horizontalCenter: parent.horizontalCenter
						top: parent.top
						topMargin: controls.height +GlobalVariables.controls.padding *2
					}
					width: parent.width -GlobalVariables.controls.padding *2
					height: width

					RectangularShadow {
						anchors.fill: trackArt
						radius: GlobalVariables.controls.radius
						offset.y: 10
						spread: 0
						blur: 30
						color: GlobalVariables.colours.shadow
						opacity: 0.975
					}

					Image { id: trackArt
						anchors.centerIn: parent
						width: Math.min(sourceSize.width, parent.width -2)
						height: Math.min(sourceSize.height, parent.height -2)
						source: root.track.art
						layer.enabled: true
						layer.effect: OpacityMask {
							maskSource: Rectangle {
								width: trackArt.width
								height: trackArt.height
								radius: GlobalVariables.controls.radius
							}
						}
					}

					// Column {
					// 	Repeater {
					// 		model: Mpris.players.values
					// 		delegate: Text {
					// 			text: modelData.metadata["xesam:asText"]
					// 			color: GlobalVariables.colours.text
					// 			font: GlobalVariables.font.regular
					// 		}
					// 	}
					// }

					// Grid {
					// 	x: 6
					// 	y: 6
					// 	rows: 16
					// 	Repeater {
					// 		model: root.track.colorQuantizer.colors
					// 		delegate: Rectangle {
					// 			width: 10
					// 			height: 10
					// 			color: modelData
					// 		}
					// 	}
					// }
				}

				// open player
				RectangularShadow {
					visible: raiseButton.visible
					anchors.fill: raiseButton
					radius: Math.min(width, height) /2
					offset { x: -2; y: 2; }
					spread: 5
					blur: 30
					color: GlobalVariables.colours.shadow
					opacity: 0.4
				}

				QsButton { id: raiseButton
					visible: activePlayer.canRaise
					onClicked: activePlayer.raise();
					anchors {
						right: parent.right
						rightMargin: GlobalVariables.controls.padding +GlobalVariables.controls.spacing
						top: parent.top
						topMargin: GlobalVariables.controls.padding +GlobalVariables.controls.spacing
					}
					content: IconImage {
						implicitSize: GlobalVariables.controls.iconSize
						source: Quickshell.iconPath("window-pop-out")
					}
				}
			}

			// album art window border
			// Rectangle {
			// 	anchors {
			// 		horizontalCenter: parent.horizontalCenter
			// 		top: parent.top
			// 		topMargin: controls.height +GlobalVariables.controls.padding *2
			// 	}
			// 	width: parent.width -GlobalVariables.controls.padding *2
			// 	height: width
			// 	radius: GlobalVariables.controls.radius
			// 	color: "transparent"
			// 	border { width: 2; color: GlobalVariables.colours.base; }
			// 	opacity: 0.25
			// }

			// track info
			ColumnLayout { id: headerLayout
				spacing: GlobalVariables.controls.spacing

				anchors {
					bottom: parent.bottom
					bottomMargin: GlobalVariables.controls.padding
				}
				width: parent.width

				Column {
					Layout.leftMargin: GlobalVariables.controls.padding
					Layout.rightMargin: GlobalVariables.controls.padding
					Layout.fillWidth: true

					// track title
					Marquee {
						width: parent.width
						content: Text {
							text: track.title
							color: GlobalVariables.colours.text
							font: GlobalVariables.font.semibold
						}
					}

					// track artist
					Marquee {
						width: parent.width
						content: Text {
							text: track.artist || "Unknown Artist"
							color: GlobalVariables.colours.windowText
							font: track.artist? GlobalVariables.font.small : GlobalVariables.font.smallitalics
						}
					}
				}
			}
		}
		body: RowLayout {
			width: screen.width /10

			Text {
				Layout.margins: GlobalVariables.controls.padding
				text: formatTime(parseInt(activePlayer.position))
				color: GlobalVariables.colours.windowText
				font: GlobalVariables.font.monosmall
				verticalAlignment: Text.AlignVCenter
			}

			Style.Slider { id: bodyProgressBar
				Layout.alignment: Qt.AlignVCenter
				Layout.fillWidth: true
				showTooltip: false
				from: 0.0
				value: activePlayer.position
				to: activePlayer.length
				onMoved: activePlayer.position = value;
				stepSize: 1
			}

			Text {
				Layout.margins: GlobalVariables.controls.padding
				text: `-${formatTime(parseInt(activePlayer.length -parseInt(activePlayer.position)))}`
				color: GlobalVariables.colours.windowText
				font: GlobalVariables.font.monosmall
				verticalAlignment: Text.AlignVCenter
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
				source: Quickshell.iconPath(activePlayer.desktopEntry, true) || Quickshell.iconPath(activePlayer.identity.toLowerCase(), "multimedia-audio-player")
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
