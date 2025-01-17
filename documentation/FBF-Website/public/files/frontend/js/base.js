$(function() {
	
	/* 
	 * Scroll to Top on Heroes Detail, Items...
	 */
	$(".scrollTop").click(function(){
		$('html').scrollTo('#header', 1000);
	});
        
        /* open Side Navi Menu ( left Side ) */
	$(".sideMenu .naviOpen").click(function(){
		var $this = $(this);
		var jScrollbar = $('.sideBox .jScrollbar');
		if ($this.hasClass('toRight')) {
			jScrollbar.hide();
			$this.removeClass('toRight');
			$this.animate({"right": "2px"}, 650, function(){
				$('.sideMenu .sideBox').show("slide", { direction: "left" }, 650, function(){
					$this.removeClass('naviOpen');
					$this.addClass('naviClose');
					$this.css('z-index', '1');
					$this.addClass('toLeft');
					jScrollbar.fadeIn(550);
					jScrollbar.jScrollbar({
						scrollStep : 8,
					    showOnHover : false,
					    sposition : 'right'
					});
				});
			});
		}
	});
	
	/* close Side Navi Menu ( left Side ) */
	$(".sideMenu .naviClose").live('click', function(){
		var $this = $(this);
		if ($this.hasClass('toLeft')) {
			$this.removeClass('toLeft');
			$('.sideMenu .sideBox').hide("slide", { direction: "left" }, 1500, function(){
				$this.animate({"right": "11px"}, 650, function(){
					$this.removeClass('naviClose');
					$this.addClass('toRight naviOpen');
				});
			});
		}
	});
	
	/*
	 * Tab Box on Hero Detail Page and Towers
	 */
	$(".tabs").tabs({
		show: function(){
			// initialize scrollbar
			if ($.fn.jScrollbar) {
				$('.panes .jScrollbar').jScrollbar({
					scrollStep : 5,
				    showOnHover : true,
				    sposition : 'right'
				});
			}
		},
		select: function(event, ui){
			$('.tabs a.tab0Active').removeClass('tab0Active');
			$('.tabs a.tab1Active').removeClass('tab1Active');
			$('.tabs a.tab2Active').removeClass('tab2Active');
			switch (ui.index) {
			case 0:
				$('.tabs a.tab0').addClass('tab0Active');
				break;
			case 1:
				$('.tabs a.tab1').addClass('tab1Active');
				break;
			case 2:
				$('.tabs a.tab2').addClass('tab2Active');
				break;
			default:
				break;
			}
		}
	});
	
	/* Media */
	$('.colorboxImages').colorbox({rel:'colorbox'});
	
	/*
	 * Facebook Comment Script
	 */
	(function(d, s, id) {
  		var js, fjs = d.getElementsByTagName(s)[0];
  		if (d.getElementById(id)) return;
  		js = d.createElement(s); js.id = id;
  		js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
  		fjs.parentNode.insertBefore(js, fjs);
	}
	(document, 'script', 'facebook-jssdk'));
});