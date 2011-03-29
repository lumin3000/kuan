$(function(){
	var $windowH = $(window).height();
	var $windowW = $(window).width();
	$('.content')
		.css({'max-height': $windowH});
	$('.image')
		.css({'max-width': $windowW});
});

$(window).load(function(){
	var $windowH = $(window).height();
	var $imageW = $('.text, .image, .photoset embed, .quote, div.link, div.chat, .video embed, .video iframe').width();
	var $top = ( $windowH - $('div.content').height() ) / 2 ;
	$('div.content')
		.width($imageW)
		.css({'margin-top': $top});
});