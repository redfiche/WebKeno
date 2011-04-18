numberClicked = (event) ->
	td = event.currentTarget
	if $(td).hasClass('number-cell')
		if $(td).hasClass('chosen')
			$(td).removeClass('chosen').addClass('clickable')
		else
			if $('.chosen').size() >= 10
				alert 'No more than ten numbers may be selected'
			else
				$(td).addClass('chosen').removeClass('clickable')
			
			
ticketCreated = () -> window.location = '/'

showValidation = (messages) ->
	validationHtml = ""
	for message in messages
		validationHtml += '<p>' + message + '</p>'
	$('#validation').html(validationHtml)

isValid = () ->
	validationMessages = []
	numberOfRaces = parseInt($('#numberOfRaces').val())
	numberOfChoices = $('.chosen').length
	validationMessages.push("Please enter a name") if $('#name').val() == ""
	validationMessages.push("Please enter number of races") unless numberOfRaces > 0
	validationMessages.push("Please choose 1 to 10 numbers") if numberOfChoices == 0
	showValidation validationMessages
	return validationMessages.length == 0

postTicket = () ->
	if isValid()
		chosen = []
		for choice in $('.chosen')
			chosen.push parseInt($(choice).html())
		ticket = 
			name: $('#name').val()
			choices: chosen
			howMany: $('#numberOfRaces').val()
		$.ajax
			type:'POST'
			url: '/newticket'
			data: ticket
			success: ticketCreated
			
$(document).ready ->
		$('td').click(numberClicked).addClass('clickable')
		$('#submitButton').click(postTicket)
			

	
  


