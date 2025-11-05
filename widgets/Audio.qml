/*-------------------------
 * --- Audio.qml by andrel ---
 * -------------------------*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import qs
import qs.controls
import qs.styles as Style

IconImage { id: root
	readonly property bool isMuted: Pipewire.defaultAudioSink?.audio.muted
	readonly property real volume: Pipewire.defaultAudioSink?.audio.volume
	readonly property TextMetrics textMetrics: TextMetrics {
		text: "100"
		font: GlobalVariables.font.regular
	}

	onIsMutedChanged: osd.showOsd();
	onVolumeChanged: osd.showOsd();
	implicitSize: GlobalVariables.controls.iconSize
	// icon reflects volume level
	source: {
		if (isMuted || !volume > 0) return Quickshell.iconPath("audio-volume-muted");
		switch (Math.round(volume /0.5) *0.5) {
			case 0:
				return Quickshell.iconPath("audio-volume-low");
			case 0.5:
				return Quickshell.iconPath("audio-volume-medium");
			case 1.0:
				return Quickshell.iconPath("audio-volume-high");
			default:
				return Quickshell.iconPath("audio-volume-high");
		}
	}

	PwObjectTracker { objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource, ...Pipewire.nodes.values.filter(n => n.isStream)]; }

	MouseArea {
		anchors.centerIn: parent
		width: parent.width +4
		height: width
		hoverEnabled: true
		onEntered: tooltipTimer.restart();
		onExited: {
			tooltipTimer.stop();
			tooltip.isShown = false;
		}
		acceptedButtons: Qt.AllButtons
		onClicked: (mouse) => {
			switch (mouse.button) {
				case Qt.LeftButton:
					popout.toggle();
					break;
				case Qt.MiddleButton: // mute on middle-mouse click
					Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
					break;
			}
		}
		onWheel: (wheel) => { // set volume on scroll
			var vol = volume;

			vol += (wheel.angleDelta.y /120) *0.05;
			Pipewire.defaultAudioSink.audio.volume = Math.min(Math.max(vol, 0.0), 1.0);

			osd.showOsd();
		}
	}

	QsTooltip { id: tooltip
		anchor: root
		content: Text {
			width: textMetrics.width
			text: `${parseInt(volume *100)}%`
			color: GlobalVariables.colours.text
			font: GlobalVariables.font.regular
			horizontalAlignment: Text.AlignHCenter
		}

		Timer { id: tooltipTimer
			running: false
			interval: 1500
			onTriggered: parent.isShown = true;
		}
	}

	Popout { id: popout
		anchor: root
		onIsOpenChanged: if (!popout.isOpen) {
			sinkDropdown.close();
			sourceDropdown.close();
		}
		header: ColumnLayout { id: headerContent
			// spacing: GlobalVariables.controls.spacing
			width: screen.width /6

			Item { Layout.preferredHeight: 1; }

			// output settings
			RowLayout {
				Layout.leftMargin: GlobalVariables.controls.padding
				Layout.rightMargin: GlobalVariables.controls.padding
				Layout.fillWidth: true

				QsButton {
					Layout.alignment: Qt.AlignVCenter
					onClicked: Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
					content: Style.Button {
						IconImage {
							anchors.centerIn: parent
							implicitSize: GlobalVariables.controls.iconSize
							source: Quickshell.iconPath("audio-speakers")
							layer.enabled: true
							layer.effect: ColorOverlay {
								property color baseColor: GlobalVariables.colours.shadow
								property color semiTransparent: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.5)

								color: Pipewire.defaultAudioSink.audio.muted? semiTransparent : "transparent"
							}
						}
					}
				}

				ColumnLayout {
					QsDropdown { id: sinkDropdown
						Layout.leftMargin: 4
						Layout.rightMargin: 4
						Layout.fillWidth: true
						onOpened: sourceDropdown.close();
						options: Pipewire.nodes.values.filter(n => n.isSink && n.description).map(n => n.description)
						selection: Pipewire.defaultAudioSink?.description
						onSelected: (option) => { Pipewire.preferredDefaultAudioSink = Pipewire.nodes.values.find(n => n.description === option); }
					}

					Style.Slider {
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignVCenter
						from: 0.0
						value: volume
						to: 1.0
						onMoved: Pipewire.defaultAudioSink.audio.volume = value;
					}
				}
			}

			Item { Layout.preferredHeight: 1; }
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

				Repeater { id: repeater
					model: Pipewire.nodes.values.filter(n => n.isStream)
					delegate: RowLayout {
						required property var modelData

						Layout.leftMargin: GlobalVariables.controls.padding
						Layout.rightMargin: GlobalVariables.controls.padding

						QsButton {
							onClicked: modelData.audio.muted = !modelData.audio.muted;
							content: Style.Button {
								color: GlobalVariables.colours.base

								IconImage {
									anchors.centerIn: parent
									implicitSize: GlobalVariables.controls.iconSize
									source: Quickshell.iconPath(modelData.properties["application.icon-name"], "multimedia-audio-player")
									layer.enabled: true
									layer.effect: ColorOverlay {
										property color baseColor: GlobalVariables.colours.shadow
										property color semiTransparent: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.5)

										color: modelData.audio.muted? semiTransparent : "transparent"
									}
								}
							}
						}

						Text {
							Layout.maximumWidth: 100
							text: modelData.properties["application.name"]
							elide: Text.ElideRight
							color: GlobalVariables.colours.text
							font: GlobalVariables.font.regular
						}

						Style.Slider {
							Layout.fillWidth: true
							Layout.minimumWidth: 200
							from: 0.0
							value: modelData.audio.volume
							to: 1.0
							onMoved: modelData.audio.volume = value;
						}
					}
				}

				// bottom padding element
				Item { Layout.preferredHeight: 1; }
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
				source: root.source
			}

			ProgressBar {
				Layout.margins: GlobalVariables.controls.padding
				Layout.leftMargin: 0
				Layout.fillWidth: true
				height: 12
				progress: volume
			}
		}
	}
}
