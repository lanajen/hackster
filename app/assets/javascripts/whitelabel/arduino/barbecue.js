$(function(){

	var newsFeedUrl = 'https://blog.arduino.cc/category/featured/feed/?json=1&callback=JSON_CALLBACK';

	var rndNum = Math.floor((Math.random()*6)+1);
	var backgroundBaseUrl = "https://s3.amazonaws.com/arduino-create-static/video/0"+rndNum;

	var videoSourceOgv = backgroundBaseUrl+".ogv";
    var videoSourceMp4 = backgroundBaseUrl+".mp4";
    var videoSourcesPoster = backgroundBaseUrl+".jpg";

    var videoEl = $('#bgvid');
    var expanded = false;

    videoEl.attr('poster', videoSourcesPoster);
    videoEl.find('#mp4').attr('src', videoSourceMp4);
    videoEl.find('#ogv').attr('src', videoSourceOgv);

	$.ajax({
	   type: 'GET',
	    url: newsFeedUrl,
	    async: false,
	    contentType: "application/json",
	    dataType: 'jsonp',
	    success: function(json) {
	       for(var i=0; i<json.posts.length; i++) {
	       		$('#news_feed').append('<a href="'+json.posts[i].url+'" target="_blank"><p>'+json.posts[i].title+'</p></a>');
	       }
	    },
	    error: function(e) {
	       console.log(e.message);
	       $('#feed_cont').removeClass('visible');
	    }
	});

	var openHome = function(){
		expanded = true;

		$('#back').attr('style', 'display: block !important');

		var hh = $('#home').height();
		var h = $('#back').height() - hh;

		$('#home')
			.css('top', -hh + 'px')
			.animate(
				{'top':'0'},
				{
				duration: 600,
				easing: 'easeInOutExpo',
				start: function(){
					$('#back').removeClass('hidden').addClass('visible');
					$('#closeArea').removeClass('hidden').addClass('visible').css('height', h +'px');
					$('#ham').addClass('hamBack').removeClass('hamNoBack');
	  			$('.arduino-bbq').addClass('bbq-overlap');

				}
	 	});

		$('body').css({
      'overflow': 'hidden'
		});
	};

	var closeHome = function() {
		var duration = 600;

		var h = $('#home').height();
		$('#home').animate(
	 		{'top': -h},
	 		{
			duration: duration,
			easing: 'easeInOutExpo',
			complete: function(){
				$('#back').removeClass('visible').addClass('hidden');
				$('#closeArea').removeClass('visible').addClass('hidden');
				$('#ham').removeClass('hamBack').addClass('hamNoBack');
  			$('#back').hide();
  			$('.arduino-bbq').removeClass('bbq-overlap');
			}
	  	});

	  	$('body').css({
		    'overflow': 'auto'
			});

	  	expanded = false;
	};

	$('.toggleNav').click(function(){
		if(expanded) {
			closeHome();
		} else {
			openHome();
		}
	});

	$('#closeArea').click(function(){
		closeHome();
	});

});