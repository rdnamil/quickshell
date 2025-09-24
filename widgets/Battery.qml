/*------------------------------
--- Battery widget by andrel ---
------------------------------*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.UPower
import ".."
import "../tools"

Item { id: root
	readonly property real percentage: 0.5
	readonly property bool isCharging: !UPower.onBattery

	// property bool showPercentage: true

	width: widget.width
	height: widget.height

	SimpleButton { id: widget
		darken: false
		animate: false
		onClicked: powerProfMenu.toggle()
		content: Item {
			width: layout.width
			height: layout.height

			RowLayout { id: layout
				spacing: 2

				// show battery percentage
				Text {
					visible: showPercentage
					height: battery.height
					text: parseInt(root.percentage *100) + "%"
					font.family: GlobalConfig.font.sans
					font.pointSize: 8
					color: GlobalConfig.colour.foreground
				}

				Item { id: icon
					width: 25
					height: 12

					// battery health bar
					Rectangle { id: healthBar
						// change colour of bar based on battery health
						readonly property string batteryHealth: {
							let health = null
							if (root.percentage <= 0.15) {
								health = GlobalConfig.colour.red
							} else if (root.percentage <= 0.33) {
								health = GlobalConfig.colour.orange
							} else {
								health = GlobalConfig.colour.green
							}
							return health;
						}

						anchors{ left: parent.left; leftMargin: 2; verticalCenter: parent.verticalCenter; }
						width: (parent.width -5) *root.percentage
						height: parent.height -4
						radius: 1
						color: batteryHealth
						layer.enabled: true
						layer.effect: DropShadow {
							color: healthBar.batteryHealth
							horizontalOffset: 0
							verticalOffset: 0
							spread: 0
							radius: 3
						}
					}

					// charging icon
					Rectangle {
						anchors.centerIn: battShell;

						Text { id: light
							anchors.centerIn: parent
							text: "󱐋"
							font.pixelSize: battShell.height -2
							color: GlobalConfig.colour.foreground
							// opacity: 0.8
							visible: root.isCharging
						}

						Text { id: dark
							anchors.centerIn: parent
							text: "󱐋"
							font.pixelSize: battShell.height -2
							color: GlobalConfig.colour.background
							// opacity: 0.8
							visible: root.isCharging
							layer.enabled: true
							layer.effect: OpacityMask {
								maskSource: Rectangle {
									width: dark.width
									height: dark.height
									color: "transparent"

									Rectangle {
										anchors.centerIn: parent
										width: battShell.width
										height: dark.height
										color: "transparent"

										Rectangle { id: mask
											anchors { left: parent.left; leftMargin: 2; }
											width: healthBar.width
											height: parent.height
										}

										Rectangle {
											anchors.left: mask.right
											width: 1
											height: parent.height
											opacity: 0.5
										}
									}
								}
							}
						}
					}

					// battery overlay
					Rectangle { id: battShell
						anchors.left: parent.left
						width: parent.width -1
						height: parent.height
						color: "transparent"
						gradient: Gradient {
							orientation: Gradient.Vertical
							GradientStop { position: 0.0; color: "#20000000" }
							GradientStop { position: 0.1; color: "#80ffffff" }
							GradientStop { position: 0.5; color: "#00000000" }
							GradientStop { position: 1.0; color: "#40000000" }
						}
						radius: 3
						border { color: GlobalConfig.colour.foreground; width: 1; }
					}

					Rectangle {
						anchors{ right: parent.right; verticalCenter: parent.verticalCenter; }
						width: 1
						height: 4
						color: GlobalConfig.colour.foreground
					}
				}
			}
		}
	}

	Popout { id: profile
		anchor: root
		content: Item { id: contentRoot
			width: contentLayout.width
			height: contentLayout.height

			Column { id: contentLayout
				leftPadding: 15
				rightPadding: 10
				topPadding: 10
				bottomPadding: 10
				spacing: 4
				Row {
					spacing: 6
					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: ""
						font.pixelSize: powersave.height -2
						color: GlobalConfig.colour.foreground
					}
					Switch { id: powersave
						anchors.verticalCenter: parent.verticalCenter
						onClicked: toggle();
						onToggled: { if (isOn && performance.isOn) performance.isOn = false; contentRoot.updatePowerProfile(); }
						Component.onCompleted: isOn = (PowerProfiles.profile === PowerProfile.PowerSaver)
					}
				}
				Row {
					spacing: 6
					Text {
						anchors.verticalCenter: parent.verticalCenter
						text: "󰠠"
						font.pixelSize: performance.height -2
						color: GlobalConfig.colour.foreground
					}
					Switch { id: performance
						anchors.verticalCenter: parent.verticalCenter
						onClicked: toggle();
						onToggled: { if (isOn && powersave.isOn) powersave.isOn = false; contentRoot.updatePowerProfile(); }
						Component.onCompleted: isOn = (PowerProfiles.profile === PowerProfile.Performance)
					}
				}
			}

			function updatePowerProfile() {
				if (powersave.isOn) {
					PowerProfiles.profile = PowerProfile.PowerSaver;
				} else if (performance.isOn) {
					PowerProfiles.profile = PowerProfile.Performance;
				} else {
					PowerProfiles.profile = PowerProfile.Balanced;
				}
			}
		}
	}

	PopoutNew { id: powerProfMenu
		anchor: root
		header: Row {
			padding: GlobalConfig.padding
			spacing: GlobalConfig.spacing

			Battery {
				// showPercent: false
				material: true
				height: 16
			}

			Text {
				anchors.verticalCenter: parent.verticalCenter
				text: `${parseInt(percentage *100)}%`
				color: GlobalConfig.colour.foreground
				font {
					family: GlobalConfig.font.sans
					pointSize: GlobalConfig.font.small
					weight: GlobalConfig.font.bold
				}
			}
		}
		body: Column {
			padding: GlobalConfig.padding
			spacing: GlobalConfig.spacing

			Row {
				spacing: GlobalConfig.spacing

				Text {
					text: ""
					color: GlobalConfig.colour.foreground
					font.pixelSize: 16
				}

				Switch {
					isOn: PowerProfiles.profile === PowerProfile.PowerSaver
					onClicked: PowerProfiles.profile = isOn? PowerProfile.Balanced : PowerProfile.PowerSaver
				}
			}

			Row {
				spacing: GlobalConfig.spacing

				Text {
					text: "󰠠"
					color: GlobalConfig.colour.foreground
					font.pixelSize: 16
				}

				Switch {
					isOn: PowerProfiles.profile === PowerProfile.Performance
					onClicked: PowerProfiles.profile = isOn? PowerProfile.Balanced : PowerProfile.Performance
				}
			}
		}
	}
}
