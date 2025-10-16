/*-------------------------
--- Audio.qml by andrel ---
-------------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "../"
import "../controls"

IconImage { id: root
	readonly property bool isMuted: Pipewire.defaultAudioSink?.audio.muted
	readonly property real volume: Pipewire.defaultAudioSink?.audio.volume

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

	Popout { id: popout
		anchor: root
		body: ColumnLayout {
			spacing: GlobalVariables.controls.spacing

			// padding element
			Item { Layout.preferredHeight: 1; }

			Repeater {
				model: Pipewire.nodes.values.filter(n => n.isSink && n.description)
				delegate: ColumnLayout {
					required property var modelData

					Layout.fillWidth: true

					QsButton {
						Layout.fillWidth: true

						shade: false
						highlight: true
						onPressed: Pipewire.preferredDefaultAudioSink = modelData;
						content: Row {
							leftPadding: GlobalVariables.controls.padding
							rightPadding: GlobalVariables.controls.padding
							spacing: GlobalVariables.controls.spacing

							QsStateButton {
								checkState: modelData.id === Pipewire.defaultAudioSink.id? Qt.Checked : Qt.Unchecked
							}

							Text { id: node
								text: modelData.description
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.small
							}
						}
					}

					Slider {
						Layout.leftMargin: GlobalVariables.controls.padding
						Layout.rightMargin: GlobalVariables.controls.padding
						Layout.fillWidth: true
						from: 0
						to: 1
						value: modelData.audio.volume
						onMoved: modelData.audio.volume = value
					}
				}
			}

			// padding element
			Item { Layout.preferredHeight: 1; }
		}
	}
}
