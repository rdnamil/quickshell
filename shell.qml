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
	// create bar on every screen
	Variants {
		model: Quickshell.screens
		delegate: Bar {
			// barHeight: 36

			leftItems: [
				Network {}
				,Bluetooth {}
				,Audio {}
				,MusicPlayer {
					minBarWidth: 100
				}
				// ,Shazam {}
			]

			centreItems: [
				NiriWorkspaces {
					// isMaterial: true
					// noTasks: true
				}
			]

			rightItems: [
				Tray {}
				,NotifyUpdate {}
				,Caffeine {}
				,Redshift {}
				,Seperator {}
				,Weather {}
				,Clock {}
				,Battery {}
				,NotificationTray {}
			]
		}
	}

	// only show on main/active monitor
	Notifications {}
	Brightness {}

	// connect to shell services
	Component.onCompleted: [
		Service.Shell.init(),
		AppLauncher.init(),
		Service.Redshift.init(
			true, // enable geo located sunset/sunrise times (static times will be ignored if 'true')
			"19:00", // static start time
			"7:00" // static end time
		)
	]
}
