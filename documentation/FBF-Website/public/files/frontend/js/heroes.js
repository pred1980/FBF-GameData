$(function() {
	/*
	 * Mouseover Effect on hero thumbnails
	 */
	$('.heroesPreviewList .unitIcon').click(function(e){
		var $this = $(this),
			heroName = $this.attr('title'),
			affilation = $this.attr('class'),
			isForsaken = false,
			tmpHeroName = '',
			hover = '',
			lastActiveHero = '',
			tmpLastActionHero = '',
			open = false, // do Ajax Request if it's a new hero
			fs = $('.fs'), // Preview Box for Forsaken
			co = $('.co'); // Preview Box for Coalition
		
		//if Hero thumb is forsaken
		if ( affilation.indexOf("Forsaken") >= 0 ) {
			isForsaken = true;
			// is Coalition PreviewBox not hidden? If yes, hide!
			if (!co.hasClass('alwaysHidden')){
				co.fadeOut(500, function(){$(this).addClass('alwaysHidden')});
			}
			// is Forsaken PreviewBox hidden? If yes, show!
			if (fs.hasClass('alwaysHidden')){
				fs.hide().removeClass('alwaysHidden').fadeIn(1000);
			}
			tmpClass = fs.find('h4').attr('class');
		} else {
			// is Forsaken PreviewBox not hidden? If yes, hide!
			if (!fs.hasClass('alwaysHidden')){
				fs.fadeOut(500, function(){$(this).addClass('alwaysHidden');});
			}
			// is Coalition PreviewBox hidden? If yes, show!
			if (co.hasClass('alwaysHidden')){
				co.hide().removeClass('alwaysHidden').fadeIn(1000);
			}
			tmpClass = co.find('h4').attr('class');
		}
		
		
		//remove active status ( hover effect + overlayer )
		lastActiveHero = $('a.unitIconHover');
		if (typeof lastActiveHero[0] !== 'undefined') {
			lastActiveHero.removeClass('unitIconHover');
			//transform Hero Name to CamelCase
			tmpLastActionHero = lastActiveHero.attr('title');
			//transform Hero Name to CamelCase
			tmpHeroName = tmpLastActionHero.replace(/(?:^|\s)\w/g, function(match) {
		        return match.toUpperCase();
		    });
			//remove spaces and remove the HeroClass which shows the Overlayer
			lastActiveHero.removeClass(tmpHeroName.replace(/\s/g, "")+"PrevIconHover");
		}
		
		//transform Hero Name to CamelCase
		tmpHeroName = heroName.replace(/(?:^|\s)\w/g, function(match) {
	        return match.toUpperCase();
	    });
		//remove spaces betw. HeroName
		hover = tmpHeroName.replace(/\s/g, "") + "PrevIconHover";
		//add Hover Classes
		$this.addClass(hover); //Overlayer
		$this.addClass('unitIconHover'); //Outer Glow
		
		//if preview box is not open
		if (typeof tmpClass === 'undefined'){
			open = true;
		//if previewbox is open and it's not the same hero the user clicked
		} else if ( typeof tmpClass !== 'undefined' && tmpClass.search(tmpHeroName.replace(/\s/g, "")) < 0) {
			open = true;
		} else {
		//if previewbox is open and it's the same hero, so do not a new ajax request
			open = false;
		}
		if (open) {
			// request AJAX content
			$.ajax({
				type: 'POST',
				url: 'heroes/previewbox',
				data: 'name=' + heroName,
				success:function(data){
					if (isForsaken) {
						fs.html(data);
					} else {
						co.html(data);
					}
					// initialize scrollbar
					$('.previewBox .jScrollbar').jScrollbar({
						scrollStep : 10,
					    showOnHover : true,
					    sposition : 'right',
					    marginPos: '7px'
					});
				}
			});
		}
		e.preventDefault();
	});
	
	/*
	 * Close Preview Box 
	 */
	$('span.close').live('click', function(){
		$(this).parent().fadeOut(500, function(){$(this).addClass('alwaysHidden');});
	});
	
	/* Scroll down to Facebook Comments */
	$('div.facebook').click(function(){
		$('html').scrollTo('.fb-commentBox', 1000);
	});
});