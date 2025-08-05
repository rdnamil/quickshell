pragma Singleton

import QtQuick
import QtQuick.Controls
import Quickshell

Singleton { id: root
	signal isShown(var content)
}
