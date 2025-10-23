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
				,Audio {}
				// ,Shazam {}
			]

			centreItems: [
				NiriWorkspaces {}
			]

			rightItems: [
				Tray {}
				,NotifyUpdate {}
				,Caffeine {}
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
