;(function ( $, window, document, undefined ) {
  $(function(){
    $('.respect-button').click(function(e){
      e.preventDefault();
      // $('#simplified-signup-popup input[name="redirect_to"]').val($(this).data('redirect-to'));
      // $('#simplified-signup-popup').fadeIn();
      var $that = $(this);
      $.get('/ab_test', {
        experiment: 'respect_button',
        control: 'normal_signup',
        alternatives: ['quick_signup']
      }, function(data){
        if (data.alternative == 'quick_signup') {
          $('#simplified-signup-popup input[name="redirect_to"]').val($that.data('redirect-to'));
          $('#simplified-signup-popup').fadeIn();
        } else {
          window.location.href = $that.attr('href');
        }
      });
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