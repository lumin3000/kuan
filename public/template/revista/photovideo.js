$(function() {
	$('.html_photoset').killPhotoset({
		photoSize: 1280
	});

	$('.video').each(function(){
		$(this).find('embed').each(function(){
			sizeRatio = $(this).attr('width') / $(this).attr('height');
			newWidth = $(this).parent().parent().width();
			newHeight = Math.round(newWidth / sizeRatio);
				$(this)
					.attr('width', newWidth)
					.attr('height', newHeight)
					.parent()
						.attr('width', newWidth)
						.attr('height', newHeight);
		});
	});
});