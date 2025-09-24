/*----------------------------
--- Clock widget by andrel ---
----------------------------*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import "clock"
import "root:"
import "root:/tools"

Item { id: root
	property string dateFormat: "MM dd yyyy"
	property string timeFormat: "hh:mm:ss a"
	property string colour: GlobalConfig.colour.foreground
	property string fontFamily: GlobalConfig.font.sans
	property int fontSize: GlobalConfig.font.size
	property int fontWeight: GlobalConfig.font.semibold

	width: widget.width
	height: widget.height

	SimpleButton { id: widget
		darken: false
		animate: false
		onClicked: calendar.toggle()
		content: Item {
			implicitWidth: layout.width
			implicitHeight: layout.height

			Row { id: layout
				spacing: 0

				Text { id: date
					text: Time.format(dateFormat)
					color: "#b8c0e0"
					font { pointSize: fontSize; family: fontFamily; }
				}
				Text { id: time
					text: Time.format(timeFormat)
					color: colour
					font { pointSize: fontSize; family: fontFamily; weight: fontWeight; }
				}
			}
		}
	}

	Popout { id: calendar
		anchor: root
		content: ColumnLayout {
			spacing: 0

			Rectangle { id: month
				Layout.fillWidth: true
				Layout.leftMargin: 10
				Layout.rightMargin: 10
				Layout.topMargin: 10
				height: 20
				radius: GlobalConfig.cornerRadius /2
				color: GlobalConfig.colour.accent

				Rectangle {
					anchors.fill: parent
					radius: parent.radius
					border { width: 1; color: "#40000000"}
					gradient:Gradient {
						orientation: Gradient.Vertical
						GradientStop { position: 0.0; color: "#80ffffff" }
						GradientStop { position: 0.1; color: "#00000000" }
					}
				}

				Text {
					anchors.centerIn: parent
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					text: Time.format("MMMM")
					color: GlobalConfig.colour.background
					font {
						family: GlobalConfig.font.sans
						pointSize: GlobalConfig.font.size
						capitalization: Font.AllUppercase
						letterSpacing: 1.5
						weight: GlobalConfig.font.bold
					}
				}

			}

			DayOfWeekRow {
				spacing: 2
				Layout.leftMargin: 10
				Layout.rightMargin: 10
				delegate: Text {
					required property string narrowName

					width: 20
					height: 10
					horizontalAlignment: Text.AlignHCenter
					// verticalAlignment: Text.AlignVCenter
					text: narrowName
					color: GlobalConfig.colour.foreground
					font { family: GlobalConfig.font.sans; pointSize: GlobalConfig.font.small; weight: GlobalConfig.font.bold; }
				}
			}

			MonthGrid { id: monthGrid
				Layout.leftMargin: 10
				Layout.rightMargin: 10
				Layout.bottomMargin: 5
				spacing: 2
				delegate: Item {
					required property var model

					width: 20
					height: 20

					transform: Scale {
						origin.x: width /2; origin.y: height /2;
						xScale: (model.month !== monthGrid.month)? 0.8 : 1.0
						yScale: (model.month !== monthGrid.month)? 0.8 : 1.0
					}

					Rectangle {
						visible: model.today
						anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; }
						width: 3
						height: width
						radius: height /2
						color: GlobalConfig.colour.accent
					}

					Text {
						anchors.centerIn: parent
						horizontalAlignment: Text.AlignHCenter
						text: model.day
						color: (model.month !== monthGrid.month)? GlobalConfig.colour.grey : GlobalConfig.colour.midground
						font { family: GlobalConfig.font.sans; pointSize: GlobalConfig.font.size; letterSpacing: 1.5; }
					}
				}
			}
		}
	}
}
