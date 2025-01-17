$(function() {
	
	var towers = {
		config: {
			iconBox : $('.towerIconsBox'),
			towerBox : $('.towerTabBox'),
			type : '',
			ordering : ''
		},
		init : function() {
			towers.config.iconBox.find('li').on('click', towers.switchTower);
			
		},
		ajaxRequest : function(){
			$.ajax({
				type: 'POST',
				url: 'towers/towerinformation',
				dataType : 'json',
				cache: true,
				data: 'type=' + towers.config.type + "&ordering=" + towers.config.ordering,
				success:function(data){
					towers.updateTowers(data);
					
				}
			}); 
		},
		switchTower : function(e){
			var $this = $(this),
				parentElem = $this.parent();
			
			//enferne das active
			towers.config.iconBox.find('li.active').removeClass('active');
			//füge das active dem neu angeklickten Tower-Icon
			$this.addClass('active');
			towers.config.type = parentElem.attr('id'),
			towers.config.ordering = $this.index() + 1;
			towers.ajaxRequest();	
			e.preventDefault();
		},
		updateTowers : function (data){
			var len = data.length;
			
			towers.config.towerBox.find('.towerData h5.abilities, .towerAbility').remove();
			
			for (var i = 0; i < len; i++) {
			    towers.config.towerBox.find('#tabs-'+ i + ' .towerImage').attr('src', "/files/frontend/img/enUS/towers/" + data[i].image);
			    towers.config.towerBox.find('#tabs-'+ i + ' .towerImage').attr('alt', data[i].name);
			    towers.config.towerBox.find('#tabs-'+ i + ' .towerImage').attr('title', data[i].name);
				towers.config.towerBox.find('#tabs-'+ i + ' .towerName').html(data[i].name);
				towers.config.towerBox.find('#tabs-'+ i + ' #lumber').html(data[i].lumber);
				towers.config.towerBox.find('#tabs-'+ i + ' #type').html(data[i].rarity);
				towers.config.towerBox.find('#tabs-'+ i + ' #dps').html(data[i].dps);
				towers.config.towerBox.find('#tabs-'+ i + ' #damage').html(data[i].damage);
				towers.config.towerBox.find('#tabs-'+ i + ' #cooldown').html(data[i].cooldown);
				towers.config.towerBox.find('#tabs-'+ i + ' #range').html(data[i].range);
				
				towers.config.towerBox.find('#tabs-'+ i + ' #desc').html(data[i].desc);
				towers.config.towerBox.find('#tabs-'+ i + ' .changelogVer').html(data[i].logVersion);
				
                                //Remove all changelogs
                                towers.config.towerBox.find('#tabs-'+ i + ' .items li').remove();
                                var substr = data[i].log.split('|');
                                //add <li> for every changelog
                                for (var k = 0; k < substr.length; k++) {
                                    $('#tabs-'+ i + ' .items').append('<li class="item hRepeats">' + substr[k] + '</li>');
                                }
                                
				var spellsLength = data[i]['spells'].length;
				if (spellsLength > 0){
					if (towers.config.towerBox.find('#tabs-'+ i + ' .towerAbilityImage').length === 0) {
						$('<h5 class="abilities">Abilities</h5>').insertAfter(towers.config.towerBox.find('#tabs-'+ i + ' #desc'));
					}
					for (var k = 0; k < spellsLength; k++) {
						$('<div class="towerAbility towAbi' + k + ' clearfix"></div>').insertAfter(towers.config.towerBox.find('#tabs-'+ i + ' .abilities'));
						$('#tabs-'+ i + ' .towAbi' + k).append( "<img class='towerAbilityImage' src='' alt='' title='' width='30' height='30'><h6 id='towerAbiName'></h6><p class='towerAbilityDescr'></p>");
						towers.config.towerBox.find('#tabs-'+ i + ' .towAbi'+ k + ' .towerAbilityImage').attr('src', "/files/frontend/img/enUS/towers/" + data[i]['spells'][k]['icon']);
						towers.config.towerBox.find('#tabs-'+ i + ' .towAbi'+ k + ' .towerAbilityImage').attr('alt', data[i]['spells'][k]['name']);
						towers.config.towerBox.find('#tabs-'+ i + ' .towAbi'+ k + ' .towerAbilityImage').attr('title', data[i]['spells'][k]['name']);
						towers.config.towerBox.find('#tabs-'+ i + ' .towAbi'+ k + ' #towerAbiName').html(data[i]['spells'][k]['name']);
						towers.config.towerBox.find('#tabs-'+ i + ' .towAbi'+ k + ' .towerAbilityDescr').html(data[i]['spells'][k]['desc']);
					}
				} 
			}
			
		}
	};
	
	towers.init();
});