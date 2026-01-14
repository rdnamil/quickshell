/*-------------------------------
--- MusicPlayer.qml by andrel ---
-------------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton { id: root
	readonly property list<MprisPlayer> players: Mpris.players.values
	readonly property MprisPlayer activePlayer: { if (players.length > 0){
		// prefer spotify if it's playing
		for (var player of players) {
			if (player.isPlaying && player.identity.toLowerCase() === "spotify") return player;
		}

		// return any player that is playing
		for (var player of players) {
			if (player.isPlaying) return player;
		}

		// prefer spotify if nothing playing
		for (var player of players) {
			if (player.identity.toLowerCase() === "spotify") return player;
		}

		// fallback to last available player
		return players[players.length - 1];
	} else return null; }

	property bool active
	// store track current data
	property var track: QtObject {
		property string title
		property string artist
		property string art: activePlayer.trackArtUrl;
		property ColorQuantizer colorQuantizer: ColorQuantizer {
			source: root.track.art
			depth: 8
			rescaleSize: 64
		}
		property color accentColour: {
			// get the average hue and val
			let avgHue = 0;
			let avgVal = 0;

			for (const c of root.track.colorQuantizer.colors) {
				avgHue += c.hsvHue;
				avgVal += c.hsvValue;
			}

			avgHue /= root.track.colorQuantizer.colors.length;
			avgVal /= root.track.colorQuantizer.colors.length;

			function circularDiff(h1, h2 = avgHue) {
				const diff = Math.abs(h1 -h2)
				return Math.min(diff, 1 -diff) *2;
			}

			const colours = Array.from(root.track.colorQuantizer.colors)
			// filter out colours that don't meet min req
			.filter(c => {
				if (c.hsvSaturation > 0.5 && c.hsvValue > 0.1) return true;
				else return false;
			})
			// sort based on hue furthest from avg & highest sat/val
			.sort((a, b) => {
				// scoring weights
				const hueWeight =  0.5;
				const satWeight = 0.25;
				const valWeight = 1 -hueWeight -satWeight; // don't edit

				// get hue diff from avg
				const a_circularHueDiff = circularDiff(a.hsvHue);
				const b_circularHueDiff = circularDiff(b.hsvHue);

				const a_score = hueWeight *a_circularHueDiff +satWeight *a.hsvSaturation +valWeight *a.hsvValue;
				const b_score = hueWeight *b_circularHueDiff +satWeight *b.hsvSaturation +valWeight *b.hsvValue;

				return b_score -a_score;
			});

			// console.log(avgHue);

			if (colours.length > 0) {
				return colours[0];
			}
			else if (avgHue < 0) return Qt.hsva(-1, 1.0, Math.max(Math.min(avgVal, 0.6), 0.3), 1.0);
			else return Qt.hsva(avgHue, 0.5, 0.5, 1.0);

			// return Qt.hsva(avgHue, 0.5, 0.5, 1.0);
		}
	}

	onActivePlayerChanged: if (!activePlayer) grace.restart();

	// update track title
	function updateTitle() {
		var title = activePlayer.trackTitle;
		track.title = title;
	}

	// update track artist
	function updateArtist() {
		var artist = activePlayer.trackArtist;
		track.artist = artist;
	}

	// unload widget after inactivity
	Timer { id: grace
		interval: 1000
		onTriggered: root.active = false;
	}

	// period that track artist can be updated
	Timer { id: trackChangedWait
		interval: 500
	}

	Connections {
		target: activePlayer

		function onTrackTitleChanged() {
			if (activePlayer.trackTitle) {
				// prevent widget from unloading
				root.active = true;
				grace.stop();

				// update the track title and artist
				root.updateTitle();
				root.updateArtist();

				// start timer to wait for track artist
				trackChangedWait.restart();

			} else grace.restart(); // start timer to unload widget on inactivity
		}

		function onTrackArtistChanged() {
			if (trackChangedWait.running) root.updateArtist();
		}
	}
}
