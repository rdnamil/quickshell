/*--------------------------------
--- Network service by andrel ---*
--------------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item { id: root
	readonly property var activeNetwork: {
		for (const network of networks) {
			if (network.inUse) return network || null;
		}
	}

	property var devices
	property var networks
	property bool radioEnabled

	function rescan() {
		rescan.running = true;
	}

	// start network monitor
	Process {
		running: true
		command: ["nmcli", "m"]
		stdout: SplitParser {
			onRead: rescan.running = true;
		}
	}

	// rescan
	Process { id: rescan
		running: true
		command: ["nmcli", "d", "w", "r"]
		stdout: StdioCollector {
			onStreamFinished: getNetworks.running = true;
		}
	}

	// list network devices
	Process { id: getDevices
		running: true
		command: ["nmcli", "-t", "d", "s"]
		stdout: StdioCollector {
			onStreamFinished: {
				// parse devices set to 'devices'
				devices = text.trim().split("\n").map(line => {
					const parts = line.split(":");
					return {
						device: parts[0],
						type: parts[1],
						state: parts[2],
						connection: parts[3] || ""
					};
				});
			}
		}
	}

	// get the status of the wifi radio
	Process { id: getRadioStatus
		running: true
		command: ["nmcli", "-t", "-f", "WIFI", "radio"]
		stdout: StdioCollector {
			onStreamFinished: {
				// set radioEnabled
				radioEnabled = text === "enabled";
			}
		}
	}

	// list networks available
	Process { id: getNetworks
		running: true
		command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "d", "w", "l"]
		stdout: StdioCollector {
			onStreamFinished: {
				// clear networks
				networks = [];

				// get a list of networks from nm
				const nets = text.trim().split("\n").map(line => {
					const parts = line.split(":");
					return {
						inUse: parts[0].trim() === "*",
						ssid: parts[1] || "",
						signal: parseInt(parts[2], 10),
						security: parts[3] || ""
					};
				});

				// deduplicate list
				const uniqueNets = [];

				if (nets.some(n => n.inUse)) uniqueNets.push(nets.find(net => net.inUse));	// push the current active network first

				for (const net of nets) {	// push network if ssid isn't already in list
					if (!uniqueNets.some(n => n.ssid === net.ssid)) uniqueNets.push(net);
				}

				// pass deduped list to networks
				networks = uniqueNets;
			}
		}
	}
}
