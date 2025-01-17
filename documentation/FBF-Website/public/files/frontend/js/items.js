$(function() {
	/*
	 * Tab Box on Items Page
	 */
	$(".tabs").tabs({
		show: function(){
			// initialize scrollbar
			$('.panes .jScrollbar').jScrollbar({
				scrollStep : 5,
			    showOnHover : true,
			    sposition : 'right'
			});
		},
		select: function(event, ui){
			var box = $(this),
				affiliation = '';
			//get affiliation
			if (box.hasClass('undead')) {
				affiliation = 'UD';
			} else if (box.hasClass('orc')) {
				affiliation = 'ORC';
			} else if (box.hasClass('human')) {
				affiliation = 'HUM';
			} else {
				affiliation = 'NE';
			}
			$('ul.' + affiliation + ' a.shop1Active').removeClass('shop1Active');
			$('ul.' + affiliation + ' a.shop2Active').removeClass('shop2Active');
			$('ul.' + affiliation + ' a.shop3Active').removeClass('shop3Active');

			switch (ui.index) {
				case 0:
					$('ul.' + affiliation + ' a.shop1').addClass('shop1Active');
					break;
				case 1:
					$('ul.' + affiliation + ' a.shop2').addClass('shop2Active');
					break;
				case 2:
					$('ul.' + affiliation + ' a.shop3').addClass('shop3Active');
					break;
				default:
					break;
			}
		}
	});
	
	$('.itemsBox ul.itemList li').click(function(e){
		var $this = $(this),
			box = $this.parents('.itemsDetailTabBox'),
			affiliation = '',
			shopId = 0,
			itemID = $this.index(),
			iName = '',
			iDesc = '',
			iCosts = 0,
			iBonus = '';
			
		//get affiliation
		if (box.hasClass('undead')) {
			affiliation = 'UD';
		} else if (box.hasClass('orc')) {
			affiliation = 'ORC';
		} else if (box.hasClass('human')) {
			affiliation = 'HUM';
		} else {
			affiliation = 'NE';
		}
		
		//get shop id
		shopId = $this.parent().attr('class');
		shopId = shopId.split("Shop");
		
		//remove active state from item before
		$this.parents('.ui-tabs-panel').find('ul.itemList li.active').removeClass('active');
		//add active class to the new clicked item
		$this.addClass('active');
		
		$.ajax({
			type: 'POST',
			url: 'items/iteminformation',
			dataType : 'json',
			cache: true,
			data: 'affiliation=' + affiliation + "&shop=" + shopId[1] + "&item=" + itemID,
			success:function(data){
				var bonusList = '';
				iName = data.iName;
				iDesc = data.iDesc;
				iCosts = data.iCosts;
				iBonus = data.iBonus;
				
				/* 
				 * set new Item Values 
				 */
				// Name
				$this.parent().next('h3').find('strong').html(iName);
				// Costs
				$this.parents('.ui-tabs-panel').find('span.goldIcon').attr('title', iCosts + " Gold");
				// Description
				$this.parents('.ui-tabs-panel').find('span.itemDesc').html(iDesc);
				// Bonus
				bonusList = $this.parents('.ui-tabs-panel').find('.jScrollbar').find('ul.bonusList');
				// remove Bonus Li-tags ( old Items Bonus Values )
				$this.parents('.ui-tabs-panel').find('.jScrollbar').find('ul.bonusList li').remove();
				// split Bonus Data
				iBonus = iBonus.split('|');
				// set new Item Bonus Values
				$.each(iBonus, function(key, value) {
					bonusList.append('<li class="item hRepeats">' + value +'</li>');
				});
			}
		}); 
		e.preventDefault();
	});
});