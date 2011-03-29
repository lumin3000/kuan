$(function() {
	$('.text, .video, .photoset, .answer, .liked_posts').each(function(){
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
	//Vimeo iFrame manipulation
	var vColor = accentColor.substr(1);
    $("iframe[src^='http://player.vimeo.com']").each(function() {
		//Clean up player src w/ set color
		var $vFrame = $(this);
		var src 	= $vFrame.attr("src");
		var player	= src.split("?")[0];
		var newSrc	= player+"?&title=0&byline=0&portrait=0&color="+vColor;
		var vBox	= $vFrame.closest('.box');
		var vWidth	= vBox.width();
		$vFrame.attr("src", newSrc);
		//Resize player based on width
		sizeRatio = $vFrame.attr("width") / $vFrame.attr("height");
		newWidth = vWidth;
		newHeight = Math.round(newWidth / sizeRatio);
		$vFrame.attr("width", newWidth).attr("height", newHeight);
    });
	//Vimeo - embedinator
    $("object[data^='http://vimeo.com']").each(function() {
        var $obj = $(this);
        var data = $obj.attr("data");
        var temp = data.split("clip_id=")[1];
        var id = temp.split("&")[0];
        var server = temp.split("&")[1];
		//Resize player based on width
		//sizeRatio = $obj.attr("width") / $obj.attr("height");
		newWidth = $obj.attr("width");
		newHeight =  $obj.attr("height");
        $obj.replaceWith(
            "<iframe src='http://player.vimeo.com/video/"+id+
            "?"+server+"&title=0&byline=0&portrait=0&color="+vColor+"' "+
            "width='"+newWidth+"' height='"+newHeight+"' frameborder='0'></iframe>"
        );
    });
	/*
		Widescreen YouTube Embeds by Matthew Buchanan & Hayden Hunter
		http://matthewbuchanan.name/451892574
		http://blog.haydenhunter.me

		Released under a Creative Commons attribution license:
		http://creativecommons.org/licenses/by/3.0/nz/
	*/
	$("object").each(function () {
			if ($(this).find("embed[src^='http://www.youtube.com']").length > 0) {
				// Identify and hide embed(s)
				var parent = $(this).parent();
				parent.css("visibility","hidden");
				var youtubeCode = parent.html();
				var params = "";
				if (youtubeCode.toLowerCase().indexOf("<param") == -1) {
					// IE doesn't return params with html(), so…
					$("param", this).each(function () {
						params += $(this).get(0).outerHTML;
					});
				}
				// Set colours in control bar to match page background
				var oldOpts = /rel=0/g;
				var newOpts = "rel=0&amp;color1=0xFFFFFF&amp;color2=0xFFFFFF";
				youtubeCode = youtubeCode.replace(oldOpts, newOpts);
				if (params != "") {
					params = params.replace(oldOpts, newOpts);
					youtubeCode = youtubeCode.replace(/<embed/i, params + "<embed");
				}
				// Extract YouTube ID and calculate ideal height
				var youtubeIDParam = $(this).find("embed").attr("src");
				var youtubeIDPattern = /\/v\/([0-9A-Za-z-_]*)/;
				var youtubeID = youtubeIDParam.match(youtubeIDPattern);
				var youtubeHeight = Math.floor(parent.find("object").width() * 0.75 + 25);
				var youtubeHeightWide = Math.floor(parent.find("object").width() * 0.5625 + 25);
				// Test for widescreen aspect ratio
				$.getJSON("http://gdata.youtube.com/feeds/api/videos/" + youtubeID[1] + "?v=2&alt=json-in-script&callback=?", function (data) {
					oldOpts = /height="?([0-9]*)"?/g;
					if (data.entry.media$group.yt$aspectRatio != null) {
						newOpts = 'height="' + youtubeHeightWide + '"';
					} else {
						newOpts = 'height="' + youtubeHeight + '"';
					}
					youtubeCode = youtubeCode.replace(oldOpts, newOpts);
					if (params != "") {
						params = params.replace(oldOpts, newOpts);
						youtubeCode = youtubeCode.replace(/<embed/i, params + "<embed");
					}
					// Replace YouTube embed with new code
					parent.html(youtubeCode).css("visibility","visible");
				});
			}
		});
		
});