/*---------------------------------------
--- Redshift.qml - services by andrel ---
---------------------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	readonly property string day: `backend = "wayland"
transition_mode = "static"
static_temp = 6500
static_gamma = 100
`
	readonly property string night: `backend = "wayland"
transition_mode = "static"
static_temp = 3300
static_gamma = 90
`
	readonly property bool enabled: (config.text() === root.night)
	readonly property string sunset: Qt.formatTime(new Date(Weather.weather?.daily.sunset[0]), "hh:mm")
	readonly property string sunrise: Qt.formatTime(new Date(Weather.weather?.daily.sunrise[1]), "hh:mm")

	property bool geo
	property string startTime
	property string endTime

	function init(geo, startTime, endTime) {
		root.geo = geo;
		root.startTime = startTime;
		root.endTime = endTime;
	}

	function toggle() {
		if (root.enabled) root.disableNightlight();
		else root.enableNightlight();
	}

	function enableNightlight () {
		config.setData(root.night);
	}
	function disableNightlight () {
		config.setData(root.day);
	}

	FileView { id: config
		path: Qt.resolvedUrl("./sunsetr.toml")
		blockWrites: true
	}

	Process {
		running: true
		command: ['sunsetr', '--config', `${Quickshell.configDir}/services/`]
		// stdout: SplitParser {
		// 	onRead: {
		// 		console.log(data)
		// 	}
		// }
	}

	SystemClock { id: clock
		readonly property string currentTime: Qt.formatTime(new Date(0,0,0,clock.hours,clock.minutes,0), "hh:mm")

		precision: SystemClock.Seconds
		onCurrentTimeChanged: {
			if (root.geo) {
				if (clock.currentTime === root.sunset) root.enableNightlight();
				else if (clock.currentTime === root.sunrise) root.disableNightlight ();
			} else {
				if (clock.currentTime === root.startTime) root.enableNightlight();
				else if (clock.currentTime === root.endTime) root.disableNightlight ();
			}
		}
	}
}
