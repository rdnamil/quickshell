/*---------------------------------
--- Quickshell config by andrel ---
---------------------------------*/

//@ pragma UseQApplication

import QtQuick
import Quickshell
import "widgets"

ShellRoot {
	// editing the config starts here
	// bars and other items can be added here

	Variants {	// creates the bar on all screens
		model: Quickshell.screens
		delegate: Bar {	// this is the default standard bar
			required property var modelData
			screen: modelData
			// properties for bars and widgets can be changed from here or
			// can be set globally from GlobalConfig.qml
			roundCorners: true
			spacing: 12
			padding: 14

			// widgets are listed within one of the three columns

			// left column
			// ---
			leftItems: [
				NetworkNew {},
				// Network {},
				// Bluetooth {},
				BluetoothNew {},
				PlayerNew {}
				// Player {}
			]

			// center column
			// ---
			centreItems: [
				// NiriWorkspaces {},
				NiriWorkspacesNew {}
			]

			// right column
			// ---
			rightItems: [
				// Tray {},
				TrayNew {},
				Separator {},
				Caffeine {},
				Weather {},
				ClockNew {},
				// Clock { dateFormat: "ddd d"; timeFormat: "hh:mm"; },
				// Battery {},
				BatteryNew {},
				// Notification {}
				NotificationNew {}
				// Power {}
				// QuickCenter {}
			]
		}
	}

	// volume and brightness OSDs
	OSDVolume {}
	OSDBrightness {}
}
