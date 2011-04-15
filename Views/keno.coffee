interval = {}

color = (choice) ->
	$('td:eq(' + (choice - 1) + ')').addClass('chosen')
	
startRace = () ->
	$('td').removeClass('chosen')
	$.get('/next_race', onLoad)

processChosen = (status) ->
	if status.chosen.length == 20
		clearInterval(interval)
		setTimeout startRace, 10000
	else
		color choice for choice in status.chosen
	
getChosen = () ->
	$.get('/next_winner.json', processChosen)
	
	
onLoad = () -> 
	getChosen()
	interval = setInterval(getChosen, 5000)
	
$(document).ready ->
	onLoad();
	$('#submitButton').attr('style', 'display:none')