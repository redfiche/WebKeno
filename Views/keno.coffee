interval = {}
nextRace = {}
time = 0

color = (choice) ->
	$('.keno-board').find('td:eq(' + (choice - 1) + ')').addClass('chosen')
	
startRace = () ->
	$('td').removeClass('chosen')
	$.get('/next_race', onLoad)
	
countdown = () ->
	$('#time').html(time)
	if (time == 0)
		clearInterval(nextRace)
		startRace()
	else
		time -= 1


processChosen = (status) ->
	$('#race-number').html(status.race_number);
	if status.chosen.length == 20
		clearInterval(interval)
		time = 45;
		nextRace = setInterval(countdown, 1000)
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