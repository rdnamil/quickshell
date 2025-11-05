/*-------------------------
 * --- Audio.qml by andrel ---
 * -------------------------*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
	readonly property TextMetrics textMetrics: TextMetrics { id: textMetrics
		font: GlobalVariables.font.regular
		text: "100%"
	}

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

	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}

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
				case Qt.MiddleButton:	// mute on middle-mouse click
					Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
					break;
			}
		}
		onWheel: (wheel) => {	// set volume on scroll
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
		onIsOpenChanged: if (!popout.isOpen) dropdown.close();
		header: RowLayout { id: headerContent
			spacing: GlobalVariables.controls.spacing
			width: screen.width /6

			QsDropdown { id: dropdown
				Layout.margins: GlobalVariables.controls.padding
				Layout.fillWidth: true
				options: Pipewire.nodes.values.filter(n => n.isSink && n.description).map(n => n.description)
				selection: Pipewire.defaultAudioSink?.description
				onSelected: (option) => { Pipewire.preferredDefaultAudioSink = Pipewire.nodes.values.find(n => n.description === option); }
			}
		}
		body: ColumnLayout { id: bodyContent
			width: screen.width /6

			Item { Layout.preferredHeight: 1; }

			RowLayout {
				Layout.leftMargin: GlobalVariables.controls.padding
				Layout.rightMargin: GlobalVariables.controls.padding

				Text {
					Layout.alignment: Qt.AlignVCenter
					Layout.preferredWidth: textMetrics.width
					text: `${parseInt(volume *100)}%`
					color: GlobalVariables.colours.windowText
					font: GlobalVariables.font.regular
					horizontalAlignment: Text.AlignRight
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

			Style.Margin { visible: repeater.count; Layout.fillWidth: true; }

			Repeater { id: repeater
				model: Mpris.players.values
				delegate: RowLayout {
					required property var modelData

					Layout.leftMargin: GlobalVariables.controls.padding
					Layout.rightMargin: GlobalVariables.controls.padding

					IconImage {
						visible: Quickshell.iconPath(modelData.desktopEntry, true) || Quickshell.iconPath(modelData.identity.toLowerCase(), true)
						implicitSize: GlobalVariables.controls.iconSize
						source: Quickshell.iconPath(modelData.desktopEntry, modelData.identity.toLowerCase())
					}

					Text {
						text: modelData.identity
						color: GlobalVariables.colours.text
						font: GlobalVariables.font.regular
					}

					Marquee { id: marquee
						Layout.fillWidth: true
						leftAlign: true
						speed: 35
						content: Text {
							text: modelData.trackTitle
							color: GlobalVariables.colours.windowText
							font: GlobalVariables.font.regular
						}
					}

					Style.Slider {
						visible: modelData.volumeSupported
						Layout.preferredWidth: 200
						Layout.alignment: Qt.AlignVCenter
						from: 0.0
						value: modelData.volume
						to: 1.0
						onMoved: modelData.volume = value;
					}
				}
			}

			Item { Layout.preferredHeight: 1; }
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
