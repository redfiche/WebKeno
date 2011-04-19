interval = {}
nextRace = {}
raceNumber = 0
raceTime = 0

color = (choice) ->
	$('.keno-board').find('td:eq(' + (choice - 1) + ')').addClass('chosen')
		
processChosen = (status) ->
	if (status.race_number != raceNumber)
		$('td').removeClass('chosen')
		raceNumber = status.race_number
	$('#race-number').html(status.race_number);
	color choice for choice in status.chosen
	
setTime = (time) ->
	raceTime = new Date()
	raceTime.setHours(time.hours)
	raceTime.setMinutes(time.minutes)
	raceTime.setSeconds(time.seconds)
	
getChosen = () ->
	$.get('/next_winner.json', processChosen)
	$.get('/next_race_time.json', setTime)	
	
displayTime = () ->
	tillNext = parseInt((raceTime - Date.now()) / 1000)
	unit = " seconds"
	if (tillNext > 60)
		tillNext = parseInt((tillNext + 30) / 60)
		unit = ' minutes'
		if (tillNext == 1)
			unit = ' minute'
	$('#time').html(tillNext + unit)
	
onLoad = () -> 
	getChosen()
	interval = setInterval(getChosen, 5000)
	setInterval(displayTime, 500)
	
$(document).ready ->
	onLoad();
	$('#submitButton').attr('style', 'display:none')