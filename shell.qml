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
			leftItems: [
				AppDresser {},
				Network {}
				,Bluetooth {}
				,Audio {}
				,MusicPlayer {}
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
	Brightness {}

	// connect to shell services
	Connections { target: Service.Shell; }
}
