$(function() {
	/*
	 * Glossary scrolling Event 
	 * url: http://www.myjqueryplugins.com/jScrollbar/demo
	 */
	 $(".jScrollbar").jScrollbar({
	      allowMouseWheel : true,
	      scrollStep : 10
	 });
	 
	 $('.glossaryPagination li').click(function(){
		 var newPage = $(this).attr('class');
		 $('.glossaryContainer').filter('.active').removeClass('active').fadeOut(350).hide();
		 $('.glossaryContainer').filter('.'+newPage).addClass('active').fadeIn(350).show();
		 $('.ui-draggable').css('top','0');
		 $('.jScrollbar_mask').css('top','0');
	 });
});