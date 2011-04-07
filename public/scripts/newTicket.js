

$(function() {
	$('td').click(numberClicked);
	$('#submitButton').click(postTicket)
});

function numberClicked(event) {
	var td = event.currentTarget;
	var checkbox = $(td).children('input')[0];
	if (checkbox.checked === true) {
		checkbox.checked = false;
		$(td).removeClass('chosen')
	}
	else {
		if ($(':checked').size() >= 10) {
			alert('No more than ten numbers may be selected');
			return;
		}
		checkbox.checked = true;
		$(td).addClass('chosen')
	}
}

function ticketCreated() {
	window.location = '/'
}

function postTicket() {
	var validationMessages = []
	var name = $('#name').val();
	if (name === "") {
		validationMessages.push("Please enter a name")
	}
	
	var races = parseInt($('#numberOfRaces').val());
	if (!races) {
		validationMessages.push("Please enter number of races");
	}
	
	var chosen = [];
	$('.chosen').each(function() {
		chosen.push(parseInt($(this).html()));
	});
	if (chosen.length == 0) {
		validationMessages.push("Please choose 1 to 10 numbers")
	}
	
	if (validationMessages.length > 0) {
		addValidation(validationMessages);
		return
	}
	
	var ticket = {
		name: name,
		choices: chosen
	}
	$.ajax({
		type: 'POST',
		url: '/newticket',
		data: ticket,
		success: ticketCreated
	});
}

function addValidation(messages) {
	var messageHtml = "";
	$.each(messages, function(index, message) {
		var h = "<p>" + message + "</p>";
		messageHtml += h;
	});
	$('#validation').html(messageHtml);
}

