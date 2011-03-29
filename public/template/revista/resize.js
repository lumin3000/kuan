$(function() {
	if (screen.width<=1024) {
		$('#container, #likes_container').css({width: '870px'});
		$('#header, #footer').css({width: '890px'});
		$('li.like_post').css({width: '134px', height: '134px'});
		$('.posts, iframe#ask_form, iframe#submit_form, .video')
			.css({width: '540px'});
	}
});