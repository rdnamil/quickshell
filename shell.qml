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
				AppDrawer {}
				,Network {}
				,Bluetooth {}
				,Audio {}
				,MusicPlayer {
					showTimeRemaining: true
				}
				// ,Shazam {}
			]

			centreItems: [
				NiriWorkspaces {}
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
	Volume {}
	Brightness {}
}
