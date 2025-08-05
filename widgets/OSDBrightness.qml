import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "root:/tools"
import "brightness"

Scope { id: root
	readonly property real brightness: Brightness.currentBright /Brightness.maxBright

	Osd { id: osd
		Connections {
			target: Brightness
			onCurrentBrightChanged: osd.showOsd()
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
						let icon = Quickshell.iconPath("display-brightness")
						if ((root.brightness ?? 0) < 0.01) {
							icon = Quickshell.iconPath("display-brightness-off")
						} else if ((root.brightness ?? 0) >= 0.01 && (root.brightness ?? 0) < 0.33)  {
							icon = Quickshell.iconPath("display-brightness-low")
						} else if ((root.brightness ?? 0) >= 0.33 && (root.brightness ?? 0) < 0.66) {
							icon = Quickshell.iconPath("display-brightness-medium")
						} else if ((root.brightness ?? 0) >= 0.66) {
							icon = Quickshell.iconPath("display-brightness-high")
						}
						return icon;
					}
				}

				ProgressBar {
					Layout.fillWidth: true
					height: 8
					fill: brightness
				}
			}
		}
	}
}
