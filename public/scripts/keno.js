function reveal_winners(winners) {
	setInterval(function() {
		var current = winners.pop();
		if (!current) {
			return;
		}
		jQuery('td:eq(' + (current - 1) + ')').addClass('chosen');
	}, 5000)
}