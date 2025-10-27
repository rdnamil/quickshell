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

	property real settingsWidth: 256

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
		onIsOpenChanged: if (!popout.isOpen) dropdown.close();
		header: RowLayout { id: headerContent
			spacing: GlobalVariables.controls.spacing

			IconImage {
				Layout.alignment: Qt.AlignVCenter
				Layout.margins: GlobalVariables.controls.padding
				Layout.rightMargin: 0

				implicitSize: GlobalVariables.controls.iconSize
				source: Quickshell.iconPath("audio-card")
			}

			QsDropdown { id: dropdown
				Layout.alignment: Qt.AlignVCenter
				Layout.preferredWidth: settingsWidth
				Layout.margins: 2
				Layout.leftMargin: 0
				options: Pipewire.nodes.values.filter(n => n.isSink && n.description).map(n => n.description)
				selection: Pipewire.defaultAudioSink.description
				onSelectionChanged: Pipewire.preferredDefaultAudioSink = Pipewire.nodes.values.find(n => n.description === selection)
			}
		}
		body: ColumnLayout { id: content
			Slider {
				Layout.minimumWidth: settingsWidth
				Layout.preferredWidth: headerContent.width
				Layout.margins: 4
				from: 0.0
				value: volume
				to: 1.0
				onMoved: Pipewire.defaultAudioSink.audio.volume = value;
			}
		}
	}
}
