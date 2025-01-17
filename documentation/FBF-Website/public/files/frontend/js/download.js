$(function() {
	$('a.download').click(function(e){
		$.delay(function(){ 
			$.ajax({
				type: 'POST',
				url: 'download/getcounter',
				success:function(data){
					$('li.counts').html(data);
				}
			});
			e.preventDefault();
		}, 1000);
	});
});