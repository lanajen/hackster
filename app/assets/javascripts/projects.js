;(function ( $, window, document, undefined ) {
  $(function(){
    $('.show-simplified-signup').click(function(e){
      e.preventDefault();
      $('#simplified-signup-popup input[name="redirect_to"]').val($(this).data('redirect-to'));
      $('#simplified-signup-popup').fadeIn();
    });

    if($('#top-project-section').length){
      //make top image height of the screen
      var $window     = $(window),
          $topSection = $('#top-project-section'),
          topHeight   = $window.height() - $topSection.offset().top;
      $topSection.css('height',topHeight);
      $window.resize(function(){
        topHeight = $window.height() - $topSection.offset().top;
        $topSection.css('height',topHeight);
      });
      //trigger to scroll page down
      $('.project-details').on('click','.js-scroll-main-project',function(){
        $('html,body').animate({scrollTop: $window.height()}, 800);
      });
      //parallax the header
      $('#project-header-in').parallaxScroll({ rate: .3, opacity: true, opacitySpread: 700});
    }

    //make scrollspy/sidebar navigation work
    $('body').scrollspy({ target: '#scroll-nav'});

    $('body').on('click', 'a.expand', function(e){
      e.preventDefault();
      target = $(this).data('target');
      $target = $(target);
      $target.toggleClass('collapsed');
      $target.slideToggle();
      if (!$target.hasClass('collapsed')) {
        smoothScrollTo($target);
      }
    });

    $('body').on('click', 'a.scroll', function(e){
      e.preventDefault();
      target = $($(this).data('target'));
      offsetTop = $(this).data('offset') || 0;
      smoothScrollTo(target,offsetTop);
    });

    $('.thumb-list-switch button').on('click', function(e){
      switcher = $(this).parent();
      $('button', switcher).removeClass('active');
      $(this).addClass('active');
      $('.thumb-list').removeClass(function (index, css) {
        return (css.match(/\bthumb-list-\S+/g) || []).join(' ');
      });
      listType = 'thumb-list-' + $(this).data('list-style');
      $('.thumb-list').addClass(listType);
      document.cookie = 'thumb-list-style=' + listType;
    });

    $('.well').on({
      mouseenter: function() {
        $('.btn-delete', this).show();
      }, mouseleave: function() {
        $('.btn-delete', this).hide();
      }
    }, '.comment');

    // triggers event for class change
    $.each(["addClass","removeClass"],function(i, methodname){
      var oldmethod = $.fn[methodname];
      $.fn[methodname] = function(){
        oldmethod.apply(this, arguments);
        this.trigger("classchange");
        return this;
      }
    });

    var delayOut = 500,
        delayIn = 200,
        setTimeoutConstIn = {},
        setTimeoutConstOut = {};

    $('.tech-card-popover').hover(function(e){
      clearTimeout(setTimeoutConstOut[$(this).data('target')]);
      var that = this;
      setTimeoutConstIn[$(this).data('target')] = setTimeout(function(){
        var target = $($(that).data('target'));
        var x = $(that).offset().left;
        if ((x + target.outerWidth()) > window.innerWidth) {
          x = $(that).offset().left + $(that).width() - target.outerWidth();
        }
        var y = $(that).offset().top + $(that).outerHeight() + 3;
        var $window = $(window);
        if ((y + target.outerHeight()) > ($window.scrollTop() + $window.height())) {
          y = $(that).offset().top - target.outerHeight() - 3;
        }
        target.css('top', y + 'px');
        target.css('left', x + 'px');
        $('.tech-card').hide();
        target.fadeIn(100);
      }, delayIn);
    }, function(e){
      clearTimeout(setTimeoutConstIn[$(this).data('target')]);
      var target = $($(this).data('target'));
      setTimeoutConstOut[$(this).data('target')] = setTimeout(function(){
        target.fadeOut(100);
      }, delayOut);
    });
    $('.tech-card').hover(function(e){
      clearTimeout(setTimeoutConstOut['#' + $(this).attr('id')]);
    }, function(e){
      var that = this;
      setTimeoutConstOut['#' + $(this).attr('id')] = setTimeout(function(){
        $(that).fadeOut(100);
      }, delayOut);
    });

    loadSlickSlider();
  });
})(jQuery, window, document);

function loadSlickSlider(){
  $('.headline-image, .image-gallery').slick({
    accessibility: false,
    speed: 500,
    fade: true,
    dots: true
  });
}

function openLightBox(id, start) {
  start = start || 0;
  $.iLightBox(
    lightBoxImages[id],
    {
      skin: 'metro-black',
      startFrom: start,
      path: 'horizontal'
    });
 }