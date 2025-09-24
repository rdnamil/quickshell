import QtQuick
import Quickshell
import Quickshell.Widgets
import "root:"
import "root:/tools"

Item { id: root
	width: widget.width
	height: widget.height

	IconImage { id: widget
		implicitSize: GlobalConfig.iconSize
		source: Quickshell.iconPath("system-shutdown")
	}
}
