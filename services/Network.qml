/*--------------------------------------
--- Network.qml - services by andrel ---
--------------------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	readonly property string networkState: status?.state || ""
	readonly property bool radioState: status?.radio || false

	property list<var> wirelessNetworks: []
	property list<var> savedNetworks: []
	property var status: []

	function controlNm(command) {
		control.exec(command);
	}

	function updateWirelessNetworks() {
		getWirelessNetworks.running = true;
	}

	function rescan() {
		scan.running = true;
	}

	function radio(toggle) {
		controlRadio.toggle = toggle? "on" : "off";
		controlRadio.running = true;
	}

	onNetworkStateChanged: {
		if (networkState === "connected") {
			getWirelessNetworks.running = true;
			Notifications.notify("network", "Quickshell", "Network", `Wireless is ${networkState} to ${status.connection}.`);
		} else if (networkState.startsWith("connected")) {
			getWirelessNetworks.running = true
			Notifications.notify("network", "Quickshell", "Network", `Wireless is ${networkState}.`)
		}
	}
	onRadioStateChanged: {
		if (!radioState) getWirelessNetworks.running = true;
		Notifications.notify("network", "Quickshell", "Network", `Wireless is ${radioState? "enabled" : "disabled"}.`);
	}

	// start the network manager monitor
	Process {
		running: true
		command: ["nmcli", "m"]
		stdout: SplitParser {
			onRead: getStatus.running = true;
		}
	}

	// get network manager status
	Process { id: getStatus
		running: true
		// printf "%s%s\n" "$(nmcli -t -f TYPE,STATE,CONNECTION,IP4-CONNECTIVITY d | head -n1)" ":$(nmcli -t -f WIFI g)"
		command: ["sh", "-c", 'printf "%s%s\n" "$(nmcli -t -f TYPE,STATE,CONNECTION,IP4-CONNECTIVITY d | head -n1)" ":$(nmcli -t -f WIFI g)"']
		stdout: StdioCollector {
			onStreamFinished: {
				const parts = text.split(":");
				status = {
					type: parts[0],
					state: parts[1],
					connection: parts[2],
					connectivity: parts[3],
					radio: parts[4].trim() === "enabled"
				};
			}
		}
	}

	// get a list of saved networks
	Process { id: getSavedNetworks
		running: true
		command: ["nmcli", "-t", "-f", "NAME,TYPE", "c", "s"]
		stdout: StdioCollector {
			onStreamFinished: {
				savedNetworks = text.trim().split("\n").map(line => {
					const parts = line.split(":");

					return {
						ssid: parts[0],
						type: parts[1]
					}
				});
			}
		}
	}

	// get a list of wireless networks
	Process { id: getWirelessNetworks
		running: true
		command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY", "d", "w"]
		stdout: StdioCollector {
			onStreamFinished: {
				// clear list
				wirelessNetworks = [];

				// parse output
				const nets = text.trim().split("\n").map(line => {
					const parts = line.split(":");

					return {
						ssid: parts[0],
						signal: parseInt(parts[1], 10),
						security: parts[2] !== ""
					}
				});

				// deduplicate list
				const uniqueNets = [];

				for (const net of nets) {	// push network if ssid isn't already in list
					if (!uniqueNets.some(n => n.ssid === net.ssid)) uniqueNets.push(net);
				}

				// pass deduped list to networks
				wirelessNetworks = uniqueNets;
			}
		}
	}

	// scan for wireless networks
	Process { id: scan
		command: ["nmcli", "d", "w", "r"]
		stdout: StdioCollector {
			onStreamFinished: getWirelessNetworks.running = true
		}
	}

	// turn the wifi radio on/off
	Process { id: controlRadio
		property string toggle: "on"

		command: ["nmcli", "r", "w", toggle]
	}

	// placeholder process to execute arbitrary commands
	Process { id: control; }
}
