import QtQuick
import QtQuick.Layouts
import QtMultimedia
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import "root:/tools"

Scope { id: root
	readonly property bool isMuted: Pipewire.defaultAudioSink?.audio.muted
	readonly property real volume: Pipewire.defaultAudioSink?.audio.volume

	Osd { id: osd
		PwObjectTracker {
			objects: [ Pipewire.defaultAudioSink ]
		}

		Connections {
			target: Pipewire.defaultAudioSink?.audio
			onMutedChanged: osd.showOsd()
			onVolumeChanged: osd.showOsd()
		}

		content: Item {
			width: 200
			height: 30

			RowLayout {
				anchors {
					fill: parent
					leftMargin: 10
					rightMargin: 15
				}
				spacing: 8

				IconImage {
					implicitSize: 16
					source: {
						let icon = Quickshell.iconPath("audio-volume-muted")
						if ((root.isMuted ?? true) || (root.volume ?? 0) < 0.01) {
							icon = Quickshell.iconPath("audio-volume-muted")
						} else if ((root.volume ?? 0) >= 0.01 && (root.volume ?? 0) < 0.33)  {
							icon = Quickshell.iconPath("audio-volume-low")
						} else if ((root.volume ?? 0) >= 0.33 && (root.volume ?? 0) < 0.66) {
							icon = Quickshell.iconPath("audio-volume-medium")
						} else if ((root.volume ?? 0) >= 0.66) {
							icon = Quickshell.iconPath("audio-volume-high")
						}
						return icon;
					}
				}

				ProgressBar {
					Layout.fillWidth: true
					height: 8
					fill: volume
				}
			}
		}
	}
}
