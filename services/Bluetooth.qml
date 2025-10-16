/*----------------------------------------
--- Bluetooth.qml - services by andrel ---
----------------------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton { id: root
	property list<var> devices
	property list<var> controllers
	property var defaultControllerAddress

	// bluetooth controller functions

	// bluetooth device functions
	function pair(address) { Quickshell.execDetached(["bluetoothctl", "pair", address]); }
	function connect(address) { Quickshell.execDetached(["bluetoothctl", "connect", address]); }
	function disconnect(address) { Quickshell.execDetached(["bluetoothctl", "disconnect", address]); }
	function trust(adrress) { Quickshell.execDetached(["bluetoothctl", "trust", address]); }

	// start blutoothctl
	Process {
		running: true
		command: ["bluetoothctl"]
		stdout: SplitParser {
			onRead: getDevices.running = true;
		}
	}

	// get default list of controllers
	Process { id: getControllers
		running: true
		command: ["bluetoothctl", "list"]
		stdout: StdioCollector {
			onStreamFinished: {
				for (const line of text.split("\n")) {
					const ctrl = line.match(/^Controller\s+([0-9A-F:]+)\s+(\S+)(?:\s+\[(\w+)\])?$/i);

					if (ctrl) {
						getControllerInfo.exec(["bluetoothctl", "show", ctrl[1]]);

						if (ctrl[3] === "default") {
							root.defaultControllerAddress = ctrl[1];
						}
					}
				}
			}
		}
	}

	// get controller info
	Process { id: getControllerInfo
		stdout: StdioCollector {
			onStreamFinished: {
				const controller = {};
				let parsing = false;

				for (const line of text.split("\n")) {
					const ctrl = line.trim().match(/^Controller\s+([0-9A-F:]+)\s*\(([^)]+)\)/i);

					if (ctrl) {
						controller.address = ctrl[1];
						controller.type = ctrl[2];
						parsing = true;
						continue;
					}

					// don't parse nested values
					if (/^[A-Za-z ]+:$/.test(line)) {
						parsing = false;
						continue;
					}

					if (parsing) {
						const kv = line.trim().match(/^(\w[\w ]*):\s*(.+)$/);

						if (kv) {
							const key = kv[1].trim().toLowerCase();
							let val = kv[2].trim();

							// convert "yes" "no" to bool
							if (val.toLowerCase() === ("yes" || "on")) val = true;
							else if (val.toLowerCase() === ("no" || "off")) val = false;

							if (controller[key]) {
								if (!Array.isArray(controller[key])) controller[key] = [controller[key]];
								controller[key].push(val);
							} else {
								controller[key] = val;
							}
						}
					}
				}

				root.controllers.push(controller);
			}
		}
	}

	// get list of devices
	Process { id: getDevices
		running: true
		command: ["bluetoothctl", "devices"]
		stdout: StdioCollector {
			onStreamFinished: {
				root.devices = [];

				const devs = text.trim().split("\n").map(line => {
					const dev = line.match(/^Device\s+([0-9A-F:]+)\s+(.+)$/i);

					return { address: dev[1] }
				});

				// get info for each device
				for (const dev of devs) {
					getDeviceInfo.exec(["bluetoothctl", "info", dev.address]);
				}
			}
		}
	}

	// get device info
	Process { id: getDeviceInfo
		stdout: StdioCollector {
			onStreamFinished: {
				let device = null;

				for (const line of text.split("\n")) {
					if (line.startsWith("Device ")) {
						// create a new device
						const dev = line.match(/^Device\s+([0-9A-F:]+)\s*(?:\(.+\))?$/i);

						if (dev) device = { address: dev[1] };
					} else if (device) {
						// parse device info
						const kv = line.trim().match(/^(\w+):\s*(.+)$/);

						if (kv) device[kv[1].toLowerCase()] = kv[2].trim();
					}
				}

				root.devices.push(device);
			}
		}
	}
}
