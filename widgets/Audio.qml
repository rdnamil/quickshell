/*-------------------------
--- Audio.qml by andrel ---
-------------------------*/

import QtQuick
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
				case Qt.MiddleButton:
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
				delegate: RowLayout {
					required property var modelData
					Layout.fillHeight: true

					QsButton {
						Layout.fillHeight: true
						shade: false
						highlight: true
						onPressed: Pipewire.preferredDefaultAudioSink = modelData.source;
						content: Column {
							topPadding: GlobalVariables.controls.padding
							bottomPadding: GlobalVariables.controls.padding
							spacing: GlobalVariables.controls.spacing

							Rectangle {
								anchors.horizontalCenter: parent.horizontalCenter
								width: GlobalVariables.controls.iconSize
								height: width
								radius: height /2
								color: modelData.id === Pipewire.defaultAudioSink.id? GlobalVariables.colours.accent :  GlobalVariables.colours.midlight

								Rectangle {
									visible: modelData.id === Pipewire.defaultAudioSink.id
									anchors.centerIn: parent
									width: parent.width *0.5
									height: width
									radius: height /2
									color: GlobalVariables.colours.text
								}
							}

							Item {
								anchors.horizontalCenter: parent.horizontalCenter
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

					ColumnLayout {
						spacing: GlobalVariables.controls.spacing
						Layout.fillHeight: true

						Item { Layout.preferredHeight: 16; }

						Item { id: bar
							property real barHeight: 0.5

							width: 8
							Layout.fillHeight: true

							Rectangle {
								anchors.centerIn: parent
								width: parent.width
								height: parent.height -GlobalVariables.controls.iconSize
								radius: height /2
								color: GlobalVariables.colours.midlight

								Rectangle {
									readonly property real maxBarHeight: parent.height -4

									anchors {
										horizontalCenter: parent.horizontalCenter
										top: parent.top
										topMargin: 2
									}
									width: parent.width -4
									height: maxBarHeight *bar.barHeight
									radius: width /2
									color: GlobalVariables.colours.accent
								}
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
