/*-------------------------
--- shell.qml by andrel ---
-------------------------*/

//@ pragma UseQApplication

import QtQuick
import Quickshell
import "widgets"

Scope { id: root
	// create bar on every screen
	Variants {
		model: Quickshell.screens
		delegate: Bar {
			leftItems: [
				Network {}
				,Bluetooth {}
				,MusicPlayer {}
				// ,Caffeine {}
				,Audio {}
				// ,Shazam {}
			]

			centreItems: [
				NiriWorkspaces {}
			]

			rightItems: [
				Tray {}
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
	Volume {}
	Brightness {}
}
