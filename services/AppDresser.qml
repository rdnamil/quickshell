/*-----------------------------------------
--- AppDresser.qml - services by andrel ---
-----------------------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	property var categories: [
		{ text: ["Utility"], icon: "applications-utilities-symbolic" },
		{ text: ["Settings"], icon: "applications-system-symbolic" },
		{ text: ["Internet", "Network"], icon: "applications-webbrowsers-symbolic" },
		{ text: ["Multimedia"], icon: "applications-multimedia-symbolic" },
		{ text: ["Game"], icon: "game-app-symbolic" },
		{ text: ["Security"], icon: "security-medium-symbolic" },
		{ text: ["Office"], icon: "applications-office-symbolic" },
		{ text: ["Development"], icon: "applications-development-symbolic" }
	]
	property var filteredFavourites: DesktopEntries.applications.values.filter(a => favourites.includes(a.name)).sort((a, b) => {
		return favourites.indexOf(a.name) -favourites.indexOf(b.name);
	});
	property var allApplications: Array.from(DesktopEntries.applications.values).sort((a, b) => a.name.localeCompare(b.name));
	property var filteredCategories: {
		var cats = [];

		for (const cat of root.categories) {
			cats.push(Array.from(DesktopEntries.applications.values.filter(a =>
			a.categories.some(c => cat.text.includes(c))
			)).sort((a, b) =>
			a.name.localeCompare(b.name)
			));
		}

		return cats;
	}

	property list<string> favourites: [
		"Ghostty",
		"Thunar File Manager",
		"Brave",
		"Mission Center",
		"Legcord",
		"Steam",
		"Lutris",
		"OBS Studio",
		"Timeshift",
		"Kate",
		"Krita",
		"Inkscape"
	]
	property string usersname

	// get user's full name
	Process {
		running: true
		command: ["sh", "-c", 'getent passwd "$USER" | cut -d: -f5 | cut -d, -f1']
		stdout: StdioCollector {
			onStreamFinished: usersname = text;
		}
	}
}
