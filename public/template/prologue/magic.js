$(window).load(function initOverlays() {
	$('.photo .media img').each(function() {
	   $(this).parent().append('<span class="imageOverlay" style="display:none;"></span>');
   	});
	
	imageOverlayProduction()
});

$(function(){
	zoomLink();	
});

function zoomLink() {
	$('.zoom').each(function(){
		var destination = $(this).find('.destination');		
		if (destination.attr('title') == $(this).find('a').attr('href')) {
			destination.addClass('zoom');
			//$(this).find('a').attr('rel', 'lightbox');
			$(this).find('a').addClass('thickbox');
		};		
	});
	
};
	
function imageOverlayProduction() {	
	$('.photo').each(function() {
		var overlayTarget = $(this).find('.media img'); 
		var imageOffset = (overlayTarget.offset().top%272);
		var imageHeight = overlayTarget.height();
		var imageWidth = overlayTarget.width();
		var finalOffset = '-140px '+Math.round(-imageOffset+10)+'px';	
		
		if (jQuery.support.opacity) {
			// $(overlayTarget).siblings('span.imageOverlay').css({'background-color':'#f0f', 'font-size':'20px'});
			$(overlayTarget).parent().find('.imageOverlay').css({'height':imageHeight, 'width':imageWidth, 'background-position':finalOffset});
	
			// $(overlayTarget).siblings('span.imageOverlay').html(imageOffset);
			$('.imageOverlay').fadeIn('fast');
		};
		
		$(this).find('.media a').css({'width':imageWidth});
	});	
}
