/*---------------------------------
--- NotifyUpdate.qml - services ---
---------------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	property list<var> updates: []

	function refresh() { getUpdates.running = true; timer.restart(); }

	Process { id: getPacmanUpdates
		running: true
		command: ["sh", "-c", 'pacman -Sl | grep "$(yay -Qqu)" | grep "installed:"']
		stdout: StdioCollector {
			onStreamFinished: {
				updates = text.trim().split("\n").map(line => {
					const parts = line.split(/\s+/);

					return {
						repo: parts[0],
						package: parts[1],
						newVersion: parts[2],
						oldVersion: parts[4].replace("]", "")
					}
				});

				getAURUpdates.running = true;
			}
		}
	}

	Process { id: getAURUpdates
		// running: true
		command: ["yay", "-Qua"]
		stdout: StdioCollector {
			onStreamFinished: {
				const aur = text.trim().split("\n").map(line => {
					const parts = line.split(/\s+/);

					return {
						repo: "aur",
						package: parts[0],
						oldVersion: parts[1],
						newVersion: parts[3]
					}
				});

				updates = updates.concat(aur);
			}
		}
	}

	Timer { id: timer
		running: true
		repeat: true
		interval: 36 **(10 *5)
		onTriggered: getUpdates.running = true;
	}
}
