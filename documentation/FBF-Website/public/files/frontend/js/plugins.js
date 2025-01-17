// usage: log('inside coolFunc', this, arguments);
// paulirish.com/2009/log-a-lightweight-wrapper-for-consolelog/
window.log = function(){
  log.history = log.history || [];   // store logs to an array for reference
  log.history.push(arguments);
  if(this.console) {
    arguments.callee = arguments.callee.caller;
    var newarr = [].slice.call(arguments);
    (typeof console.log === 'object' ? log.apply.call(console.log, console, newarr) : console.log.apply(console, newarr));
  }
};

// make it safe to use console.log always
(function(b){function c(){}for(var d="assert,count,debug,dir,dirxml,error,exception,group,groupCollapsed,groupEnd,info,log,timeStamp,profile,profileEnd,time,timeEnd,trace,warn".split(","),a;a=d.pop();){b[a]=b[a]||c}})((function(){try
{console.log();return window.console;}catch(err){return window.console={};}})());

/*
 * Scroll Animation
 * to: className
 */

$.fn.scrollTo = function ( to ){
	return this.each(function(){
		$('html,body').animate({scrollTop: $(to).offset().top},'slow');
	});
	
};

/*
 * extended Delay
 * use: $.delay(function(){ ... }, 2000);
 */
$.extend({
	delay: function(callback, msec) {

    if(typeof callback == 'function'){
    	setTimeout(callback, msec);
    }
  }
});

/*
 * Simple wrapper enabling setTimout within chained functions.
 * url: http://docs.jquery.com/Cookbook/wait
 */

$.fn.wait = function(time, type) {
    time = time || 1000;
    type = type || "fx";
    return this.queue(type, function() {
        var self = this;
        setTimeout(function() {
            $(self).dequeue();
        }, time);
    });
};