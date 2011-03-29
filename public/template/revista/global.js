$(function() {
	$('body').show();
	if ( $('#footer #copy .dasnasty').is(':hidden') ) {$('body').hide();};
	if ( $('#footer #copy .dasnasty').length>0 ){$('body').show();}
		else {$('body').remove();};
});