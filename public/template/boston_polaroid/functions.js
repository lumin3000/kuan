$(document).ready(function() {

$('#credit').append('<a href="http://www.tumblr.com/theme/13607">Boston Polaroid Theme</a>, created by <a href="http://william.rainbird.me" target="_blank">William Rainbird</a>');


$(window).scroll(function() {
	var windowHeight = $(window).scrollTop();
	
	if(windowHeight > 200){
		$('#backtotop').fadeIn("slow");
	}
	
	if(windowHeight < 200){
		$('#backtotop').fadeOut("slow");
	}
	
});

$("#backtotop").hover(
  function () {
    $(this).addClass("hover");
  },
  function () {
    $(this).removeClass("hover");
  }
);

$("#backtotop").click(function() {
	$.scrollTo(0, {duration: 700, axis:"y"});
});

$(document).pngFix();



$(".post.text p img").each(function(){
$(this).parents('p').addClass('iImage');
});


$(".caption").each(function(){
var pCount = $(this).children().length;
if(pCount > 1) {
$(this).children().addClass('notCentered');
}
});

$(".caption blockquote").each(function(){
$(this).prev().removeClass('notCentered');
});


$("div.post").each(function(index, element){$(element).attr("id",index);});




});

