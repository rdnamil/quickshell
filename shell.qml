/*-------------------------
--- shell.qml by andrel ---
-------------------------*/

//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services as Service
import qs.widgets

Scope { id: root
	property var colour: GlobalVariables.colours

	// create bar on every screen
	Variants {
		model: Quickshell.screens
		delegate: Bar {
			// barHeight: 36

			leftItems: [
				Power {}
				,Network {}
				,Bluetooth {}
				,Audio {}
				,MusicPlayer {
					minBarWidth: 100
				}
				// ,Shazam {}
			]

			centreItems: [
				// NiriWorkspaces {
				// 	// colours: [colour.highlight] // list of possible highlight colours
				// 	clean: false // hide windows' dots
				// }
				NiriWorkspaces_Alt {}
			]

			rightItems: [
				Tray {}
				,NotifyUpdate {}
				,Caffeine {}
				,Redeye {}
				,Seperator {}
				,Weather {}
				,Clock {}
				,Battery {}
				,NotificationTray {}
			]
		}
	}

	// only show on main/active monitor
	Brightness {}

	// connect to shell services
	Component.onCompleted: [
		Service.Shell.init(),
		Settings_Alpha.init(),
		// Settings_Beta.init(),
		Lockscreen.init(),
		Notifications.init(),
		AppLauncher.init(
			10, // the maximum number of lines to display
			true // hide category filters
		),
		Service.Redeye.init(
			5500, // temperature in K
			95, // gamma (0-100)
			true, // enable geo located sunset/sunrise times (static times will be ignored if 'true')
			"19:00", // static start time
			"7:00" // static end time
		)
	]
}
