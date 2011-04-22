interval = {}
nextRace = {}
raceNumber = 0
raceTime = 0

color = (choice) ->
	$('.keno-board').find('td:eq(' + (choice - 1) + ')').addClass('chosen')
	
updateLeaders = (leaders) ->
	leaderDiv = $('#leaderboard')
	leaderDiv.html("")
	for leader in leaders
		do (leader) ->
			html = "<p>" + leader + "</p>"
			leaderDiv.append(html) 
		
processChosen = (status) ->
	if not status.race_number?
		return
	if (status.race_number != raceNumber)
		$('td').removeClass('chosen')
		raceNumber = status.race_number
		$.get('/leaders.json', updateLeaders)
	$('#race-number').html(status.race_number);
	color choice for choice in status.chosen
	
setTime = (time) ->
	if time?
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
	if (tillNext < 0) 
		tillNext = 0
	if tillNext
		$('#time').html(tillNext + unit)
	else
		$('#time').html("unknown")
	
onLoad = () -> 
	getChosen()
	interval = setInterval(getChosen, 5000)
	setInterval(displayTime, 500)
	$.get('/leaders.json', updateLeaders)
	
$(document).ready ->
	onLoad();
	$('#submitButton').attr('style', 'display:none')