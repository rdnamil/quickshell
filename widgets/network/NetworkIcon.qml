import QtQuick
import Quickshell
import Quickshell.Widgets
import "root:"

IconImage { id: root
	required property var network

	property bool showLock: true

	implicitSize: GlobalConfig.iconSize
	source: {
		if (network) {
			const signalStrength = Math.round(network.signal /25) *25;

			switch (signalStrength) {
				case 0:
					return Quickshell.iconPath("network-wireless-signal-none");
				case 25:
					return Quickshell.iconPath("network-wireless-signal-weak");
				case 50:
					return Quickshell.iconPath("network-wireless-signal-ok");
				case 75:
					return Quickshell.iconPath("network-wireless-signal-good");
				case 100:
					return Quickshell.iconPath("network-wireless-signal-excellent");
				default:
					return Quickshell.iconPath("nm-no-connection");
			}
		} else {
			return Quickshell.iconPath("nm-no-connection");
		}
	}

	IconImage {
		visible: showLock && network.security
		anchors { right: parent.right; bottom: parent.bottom; }
		implicitSize: parent.implicitSize /2.5
		source: Quickshell.iconPath("network-wireless-encrypted")
	}
}
