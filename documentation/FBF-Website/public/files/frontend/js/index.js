$(function(){
    var index = function(){
        //General Objects
        this.sharedObjects = {
            
        };
        this.init = function() {
             this.HostBot.init(this);
             this.Gallerie.init(this);
        },
        //Hostbot
        this.HostBot = {
            objects : {
                'hostBotTable' : $('.tableStats tbody'),
                'interval' : 10000,
                'runInterval' : true
            },
            init : function(){
                this.onAddEvents();
            },
    
            sharedFunction : function(){
    
            },
            onAddEvents : function(){
                this.onEvents.onIntervalEvents.onInit(this);
            },
            onEvents : {
                onInitEvents: {
                    'onInitZClip' : function($this){
                    	$("[class^=copyFromBotId_]").zclip({
                            path: 'files/frontend/img/enUS/misc/ZeroClipboard.swf',
                            copy: function(){
                                return $(this).parents('td').find('strong').text();
                            },
                            afterCopy: function(){
                                return $(this).parents('td').find('strong').text();
                            }
                        });
                    	$this.onEvents.onClickEvents.onClickCopy();
                    }
                },
                onIntervalEvents : {
                    'onInit' : function($this){
                        $.ajax({
                            url: "index/ghopple",
                            cache: false,
                            dataType: 'text',
                            success : $.proxy(function(data) {
                                $($this.objects.hostBotTable).html(data);
                                
                                $this.onEvents.onInitEvents.onInitZClip($this);
                                
                                if ($this.objects.runInterval){
                                	$this.onEvents.onIntervalEvents.onInterval($this);
                                }
                            }, this)
                        });
                    },
                    'onInterval' : function($this){
                        $.ajax({
                            url: "index/ghopple",
                            cache: false,
                            dataType: 'text',
                            success : $.proxy(function(data) {
                                $($this.objects.hostBotTable).html(data);
                                
                                $this.onEvents.onInitEvents.onInitZClip($this);
                                
                                setTimeout(function(){
                                    $this.onEvents.onIntervalEvents.onInterval($this);
                                }, $this.objects.interval);
                            }, this)
                        });
                    }
                },
                onClickEvents : {
                    //enter some Events functions here
                    'onClickCopy' : function(e){
                    	$('.copyIcon').on('click', function(e){e.preventDefault();});
                    	$('body').on('mouseenter', '.zclip' , function(e){
                    		var target = $(e.currentTarget),
                    			copyText = target.prev().attr('title'),
                    			gamename = target.parents('td').find('strong').text();
                    		
                    		target.attr('title', (copyText + " " + gamename)).show();
                    	});
                    }
                }
            }
        };
        //Image Slider ( Gallerie )
        this.Gallerie = {
            objects : {
    
            },
            init : function(){
                this.onAddEvents();
            },
    
            sharedFunction : function(){
    
            },
            onAddEvents : function(){
                this.onEvents.onLoadEvents.InitGalleries();
            },
            onEvents : {
                onLoadEvents : {
                    'InitGalleries' : function(){
                        if ($('#screenshots').length > 0) {
                            Galleria.configure({
                                lightbox : true
                            });
                             // Initialize Screenshots
                            Galleria.run('#screenshots', {
                                autoplay : false,
                                showImagenav : false,
                                showInfo : false,
                                showCounter : false
                            });
                        }
                        
                        if ($('#gameFeatures').length > 0) {
                            Galleria.run('', {
                                autoplay : false,
                                showImagenav : true,
                                showInfo : true,
                                thumbnails: false,
                                thumbMargin: 0,
                                imagePosition : '0 30px',
                                showCounter : true
                            });
                            Galleria.ready(function() {
                                $('#gameFeatures .galleria-thumbnails-container').remove();
                            });
                        }
                    }
                }
            }
        };
        
    };
    
    if ($('#wrapper').length){
        var i = new index();

        i.init();
    }
});