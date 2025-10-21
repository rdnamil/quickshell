/*-------------------------
 * --- Audio.qml by andrel ---
 * -------------------------*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
		body: RowLayout {
			spacing: GlobalVariables.controls.spacing

			// padding element
			Item { Layout.preferredWidth: 1; }

			Repeater {
				model: Pipewire.nodes.values.filter(n => n.isSink && n.description)
				delegate: QsButton {
					required property var modelData

					Layout.fillHeight: true
					shade: false
					highlight: true
					onPressed: Pipewire.preferredDefaultAudioSink = modelData;
					content: Column {
						topPadding: GlobalVariables.controls.padding
						bottomPadding: GlobalVariables.controls.padding
						spacing: GlobalVariables.controls.spacing

						// radio button shows default adiosink
						Rectangle {
							readonly property bool isDefaultAudioSink: modelData.id === Pipewire.defaultAudioSink.id

							width: GlobalVariables.controls.iconSize
							height: width
							radius: height /2
							color: isDefaultAudioSink? GlobalVariables.colours.accent : GlobalVariables.colours.midlight

							Rectangle {
								visible: parent.isDefaultAudioSink
								anchors.centerIn: parent
								width: parent.width *0.5
								height: width
								radius: height /2
								color: GlobalVariables.colours.text
							}
						}

						// rotated text
						// pipewire node description
						Item {
							width: node.height
							height: node.width

							Text { id: node
								anchors.centerIn: parent
								text: modelData.description
								color: GlobalVariables.colours.text
								font: GlobalVariables.font.small
								rotation: 270
							}
						}
					}
				}
			}

			// padding element
			Item { Layout.preferredWidth: 1; }
		}
	}
}
