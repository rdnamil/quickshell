/*--------------------------------------------
--- Notifications.qml - services by andrel ---
--------------------------------------------*/

pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

Singleton { id: root
	readonly property ListModel model: ListModel { id: notificationModel }
	readonly property NotificationServer server: NotificationServer {

		keepOnReload: true
		actionsSupported: true
		bodyHyperlinksSupported: true
		bodyImagesSupported: true
		bodyMarkupSupported: true
		imageSupported: true

		onNotification: notification => {
			notification.tracked = true;
			if (!dnd) notificationModel.insert(0, notification);
		}
	}

	property bool dnd

	signal allRead()

	function notify(icon, name, summary, body) {
		control.exec(["notify-send", "-i", icon, "-a", name, summary, body])
	}

	Process { id: control; }

	IpcHandler {
		target: "notificationServer"
		function toggleDnd(): string { root.dnd = !root.dnd; return dnd? "Do not disturb enabled." : "Do not distrub disabled."; }
	}
}
