function reveal_winners(winners) {
	setInterval(function() {
		var current = winners.pop();
		if (!current) {
			getNewRace();
			return;
		}
		jQuery('td:eq(' + (current - 1) + ')').addClass('chosen');
	}, 5000)
}

function getNewRace() {
	setTimeout(reload, 5000);
}

function reload() {
	window.location = '/';
}
