;(function ( $, window, document, undefined ) {
  $(function(){
    if($('#top-bg-image').length){
      $('#top-bg-image').parallaxScroll({ rate: .5 });
    }
  });

  //Parallax Background Image on Scroll
  $.fn.parallaxScroll = function(options){
    return this.each(function() {
        var $this    = $(this),
            data     = $this.data('plugin_parallaxScroll');
        if(!data) {
            data = new parallaxScroll(this, options);
            $this.data('plugin_parallaxScroll', data);
        }
    });
  }
  var parallaxScroll = function parallaxScroll(element, options){
    this.$el        = $(element);
    this.rate       = .5 || options.rate;
    this.activate();
  };
  parallaxScroll.prototype = {
    activate: function(){
      var $window = $(window);
      $window.scroll(function() {
        $.throttle(this.scroll(), 100);
      }.bind(this));
    },
    scroll: function(){
      var yOffset = window.pageYOffset,
          val     = yOffset*this.rate;
      this.$el.css({
          '-webkit-transform':'translate3d(0,'+val+'px,0)',
          '-moz-transform':'translate3d(0,'+val+'px,0)',
          '-o-transform':'translate3d(0,'+val+'px,0)',
          '-ms-transform':'translate3d(0,'+val+'px,0)',
          'transform':'translate3d(0,'+val+'px,0)'
        });
    }
  };
})(jQuery, window, document);