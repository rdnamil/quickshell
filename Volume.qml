/*--------------------------
--- Volume.qml by andrel ---
--------------------------*/

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.controls

Osd { id: root
	readonly property bool isMuted: Pipewire.defaultAudioSink?.audio.muted
	readonly property real volume: Pipewire.defaultAudioSink?.audio.volume

	onIsMutedChanged: root.showOsd();
	onVolumeChanged: root.showOsd();
	content: RowLayout {
		width: 160
		spacing: GlobalVariables.controls.spacing

		IconImage {
			Layout.margins: GlobalVariables.controls.padding
			Layout.rightMargin: 0
			implicitSize: GlobalVariables.controls.iconSize
			source: {
				if (!volume > 0) return Quickshell.iconPath("audio-volume-muted");
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

			IconImage {
				visible: isMuted
				anchors {
					right: parent.right
					rightMargin: -4
					bottom: parent.bottom
					bottomMargin: -3
				}
				implicitSize: 10
				source: Quickshell.iconPath("close")
				layer.enabled: true
				layer.effect: DropShadow {
					color: GlobalVariables.colours.base
					radius: 0
					samples: 1
					spread: 1.0
					horizontalOffset: -1
					verticalOffset: -2
				}
			}
		}

		ProgressBar {
			Layout.margins: GlobalVariables.controls.padding
			Layout.leftMargin: 0
			Layout.fillWidth: true
			height: 12
			progress: volume
		}
	}

	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}
}
