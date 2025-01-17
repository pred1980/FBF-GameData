$(function() {
	/*
	 * open/close Events for the forsaken/coalition "accordion" on heroes startpage
	 */
	$('span.open').click(function(e){
		var el = $(this).parent().next('div.heroesBox');
		if (el.hasClass('alwaysHidden')){
			$(this).html('close');
			el.slideDown('slow', function() {
				el.removeClass('alwaysHidden');
			  });
		}else{
			$(this).html('open');
			el.slideUp('slow', function() {
				el.addClass('alwaysHidden');
			  });
		}
		e.preventDefault();
	});
	
	/*
	 * Mouseover Effect on hero thumbnails
	 */
	$('.thumb').mouseover(function(e){
		var heroName = $(this).attr('name'),
			xPos	 = e.pageX,
			yPos	 = e.pageY;
		$.delay(function(){
			lightbox(null, 'heroes/lightbox', 'POST', 'name='+heroName, xPos, yPos);
		}, 1000);
	}).mouseout(function(){
		closeLightbox();
	});
	
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
	
//	$("#newHero1").tabtastic();
//	$("#newHero2").tabtastic();
//	$("#newHero3").tabtastic();
});