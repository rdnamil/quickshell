/*------------------------------
--- Brightness.qml by andrel ---
------------------------------*/

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "controls"

Osd { id: root
	readonly property real brightness: currentBrightness /maxBrightness

	property int maxBrightness
	property int currentBrightness

	onCurrentBrightnessChanged: showOsd();
	content: RowLayout {
		width: 160
		spacing: GlobalVariables.controls.spacing

		IconImage {
			Layout.margins: GlobalVariables.controls.padding
			Layout.rightMargin: 0
			implicitSize: GlobalVariables.controls.iconSize
			// source: Quickshell.iconPath("display-brightness")
			source: {
				switch (Math.round(brightness /(1 /3)) *(1 /3)) {
					case 0:
						return Quickshell.iconPath("display-brightness-off");
					case 1 /3:
						return Quickshell.iconPath("display-brightness-low");
					case 2 /3:
						return Quickshell.iconPath("display-brightness-medium");
					case 1.0:
						return Quickshell.iconPath("display-brightness-high");
					default:
						return Quickshell.iconPath("display-brightness");
				}
			}
		}

		// get the maximum brightness value
		Process {
			running: true
			command: ["brightnessctl", "max"]
			stdout: StdioCollector {
				onStreamFinished: {
					root.maxBrightness = parseInt(text)
				}
			}
		}

		// get the current brightness value
		Process { id: getCurrentBrightness
			running: true
			command: ["brightnessctl", "get"]
			stdout: StdioCollector {
				onStreamFinished: {
					root.currentBrightness = parseInt(text)
				}
			}
		}

		// listen for backlight events and update the current brightness on UDEV event
		Process {
			running: true
			command: ["udevadm", "monitor", "--subsystem-match=backlight"]
			stdout: SplitParser {
				splitMarker: "UDEV"
				onRead: getCurrentBrightness.running = true
			}
		}

		ProgressBar {
			Layout.margins: GlobalVariables.controls.padding
			Layout.leftMargin: 0
			Layout.fillWidth: true
			height: 12
			progress: brightness
		}
	}
}
