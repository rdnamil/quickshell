# Quickshell
My waybar inspired quickshell config.

![screenshot](resources/Screenshot_001)

## About
A minimalist and customizable quickshell config inspired by waybar.
### Features
- Simple configuration.
- Modular and easily extendable widget system.
- Clean default theme using system colours.
- QML provides a simple JSON-like syntax.

Most configuration can be done from one of two files, `shell.qml` to configure the widgets, and `GlobalVariables.qml` to configure default values. 

An example config: 
```qml
import QtQuick
import Quickshell
import "widgets"

Scope {
	// create a bar on every screen
	Variants {
		model: Quickshell.screens
		delegate: Bar {
			leftItems: [
				MusicPlayer {},
				Audio {},
				Shazam {}
			]
			
			centreItems: [
				NiriWorkspaces {}
			]
			
			RightItems [
				Tray {},
				Seperator {},
				Clock {},
				Network {},
				Bluetooth {},
				Battery {},
				NotificationTray {}
			]
		}
	}
	
	// only show on main/active screen
	Notifications {}
	Volume {}
	Brightness {}
}
```

## Installation
### Dependencies
- `quickshell`
- `brightnessctl`
- `networkmanager`
- `songrec`
- `qt6-base`

### Arch
```bash
yay -S quickhsell
git clone https://github.com/rdnamil/quickshell
mv quickshell $HOME/.config/quickshell
qs
```

> [!note]
> Make a line in your WM config to startup quickshell on session start.
> > Ex. Niri: `spawn-at-startup "qs"`
