$(function() {
	var $contentW = $(window).width()/5;
	var $contentH = $(window).height()/3;
	$('.content')
		.css({'float':'left', //
			'opacity':0.5, //
			'overflow':'hidden'
		})
		.width($contentW)
		.height($contentH)
		.hover(
			function(){$(this).animate({'opacity':1});}, 
			function(){$(this).animate({'opacity':0.5});}
		);
	$('.content img')
		.css({'margin-left':'-30%'})
		.width($contentW+200);
	$('.photoset embed, .video embed, .video iframe')
		.width($contentW)
		.height($contentH);
	$('.text, .quote, div.link, div.chat')
		.css({'overflow':'hidden'})
		.height($contentH - 20);
	$('div.permalink')
		.css({'background':'black','position':'absolute','opacity':0.1})
		.width($contentW)
		.height($contentH)
		.hover(
			function(){$(this).animate({'opacity':0});}, 
			function(){$(this).animate({'opacity':0.1});}
		);
});

$(window).load(function(){
	$('.html_photoset').killPhotoset({photoSize: 1280});
});