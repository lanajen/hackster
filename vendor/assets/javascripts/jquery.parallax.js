;(function ( $, window, document, undefined ) {
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
    this.rate       = options.rate || .5;
    if(options.opacity){
      this.opacity        = true;
      this.opacitySpread  = options.opacitySpread || 500;
    }
    this.activate();
  };
  parallaxScroll.prototype = {
    activate: function(){
      var $window = $(window);
      if(this.opacity){
        $window.scroll(function() {
          $.throttle(this.scrollWithOpacity(), 100);
        }.bind(this));
      } else {
        $window.scroll(function() {
          $.throttle(this.scroll(), 100);
        }.bind(this));
      }
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
    },
    scrollWithOpacity: function(){
      var yOffset = window.pageYOffset,
          val     = yOffset*this.rate,
          opacity = 1 - (yOffset/this.opacitySpread),
          opacity = (opacity < 0) ? 0 : opacity;
      this.$el.css({
          '-webkit-transform':'translate3d(0,'+val+'px,0)',
          '-moz-transform':'translate3d(0,'+val+'px,0)',
          '-o-transform':'translate3d(0,'+val+'px,0)',
          '-ms-transform':'translate3d(0,'+val+'px,0)',
          'transform':'translate3d(0,'+val+'px,0)',
          '-moz-opacity': opacity,
          '-khtml-opacity': opacity,
          'opacity': opacity
      });
    }
  };
})(jQuery, window, document);