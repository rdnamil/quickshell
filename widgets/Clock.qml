/*-------------------------
--- Clock.qml by andrel ---
-------------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs
import qs.controls
import qs.styles as Style

QsButton { id: root
	shade: false
	anim: false
	onClicked: popout.toggle();
	content: Row {
		spacing: 4

		SystemClock { id: clock
			precision: SystemClock.Seconds
		}

		// date
		Text {
			text: Qt.formatDateTime(clock.date, "ddd d")
			color: GlobalVariables.colours.windowText
			font : GlobalVariables.font.regular
		}

		// devider
		Rectangle {
			anchors.verticalCenter: parent.verticalCenter
			width: 4
			height: width
			radius: height /2
			color: GlobalVariables.colours.text
		}

		// time
		Text {
			text: Qt.formatDateTime(clock.date, "hh:mm")
			color: GlobalVariables.colours.text
			font: GlobalVariables.font.semibold
		}
	}

	Popout { id: popout
		readonly property date today: clock.date
		readonly property int totalDays: popout.daysInMonth(popout.year, popout.month)
		readonly property int startOffset: popout.firstWeekday(popout.year, popout.month)

		property int month: today.getMonth()
		property int year: today.getFullYear()

		function daysInMonth(y, m) { return new Date(y, m + 1, 0).getDate(); }
		function firstWeekday(y, m) { return new Date(y, m, 1).getDay(); }
		function resetDate() {
			popout.month = today.getMonth();
			popout.year = today.getFullYear();
		}

		onIsOpenChanged: if (!isOpen) popout.resetDate();
		anchor: root
		header: RowLayout {
			width: screen.width /7

			// goto previous calendar month
			QsButton {
				Layout.margins: GlobalVariables.controls.padding
				tooltip: Text {
					text: "Go to previous calendar month"
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.italic
				}
				onClicked: {
					if (popout.month === 0) {
						popout.month = 11;
						popout.year--;
					} else popout.month--;
				}
				content: Style.Button {
					IconImage {
						anchors.centerIn: parent
						implicitSize: GlobalVariables.controls.iconSize
						source: Quickshell.iconPath("arrow-left")
					}
				}
			}

			QsButton { id: calendarMonth
				Layout.fillWidth: true

				onClicked: popout.resetDate();
				content: Text {
					width: calendarMonth.width
					text: Qt.formatDate(new Date(popout.year, popout.month, 1), "MMMM yyyy")
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.semibold
					horizontalAlignment: Text.AlignHCenter
				}
			}

			// goto next calendar month
			QsButton {
				Layout.margins: GlobalVariables.controls.padding
				Layout.alignment: Qt.AlignRight
				tooltip: Text {
					text: "Go to next calendar month"
					color: GlobalVariables.colours.text
					font: GlobalVariables.font.italic
				}
				onClicked: {
					if (popout.month === 11) {
						popout.month = 0;
						popout.year++;
					} else popout.month++;
				}
				content: Style.Button {
					IconImage {
						anchors.centerIn: parent
						implicitSize: GlobalVariables.controls.iconSize
						source: Quickshell.iconPath("arrow-right")
					}
				}
			}
		}
		body: ColumnLayout {
			width: screen.width /7

			GridLayout {
				Layout.fillWidth: true
				Layout.margins: GlobalVariables.controls.padding
				columns: 7
				uniformCellWidths: true
				uniformCellHeights: true

				Repeater {
					model: ["S", "M", "T", "W", "T", "F", "S"]
					delegate: Text {
						Layout.fillWidth: true
						Layout.preferredHeight: GlobalVariables.controls.iconSize
						text: modelData
						color: GlobalVariables.colours.text
						font: GlobalVariables.font.smallbold
						horizontalAlignment: Text.AlignHCenter
					}
				}

				Repeater {
					model: popout.startOffset +popout.totalDays
					delegate: QsButton { id: calendarDay
						required property var modelData
						required property int index

						readonly property bool isToday: (index >= popout.startOffset && (index -popout.startOffset +1) === popout.today.getDate() && popout.year === popout.today.getFullYear() && popout.month === popout.today.getMonth())

						Layout.fillWidth: true
						content: Text {
							width: calendarDay.width
							text: (index >= popout.startOffset)? (index -popout.startOffset +1).toString() : ""
							color: isToday? GlobalVariables.colours.accent : GlobalVariables.colours.text
							font: isToday? GlobalVariables.font.semibold : GlobalVariables.font.regular
							horizontalAlignment: Text.AlignHCenter
						}
					}
				}
			}
		}
	}
}
