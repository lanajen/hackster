;(function ( $, window, document, undefined ) {
  $(function(){
    if($('.top-banner-image').length){
      $('.top-banner-image').parallaxScroll({ rate: .5, opacity: true, opacitySpread: 300 });
    }

    $('.group-nav .visible-xs .nav a').on('click', function(e){
      closeNav($(this).parent().parent());
    });

    $('.close-nav').on('click', function(e){
      e.preventDefault();
      closeNav($(this).parent().parent());
    });

    $('.submenu-mobile-open').on('click', function(e){
      e.preventDefault();
      $(this).slideUp(function(){
        $(this).next().slideDown();
      });
    });

    $('.group-nav.affixable').on('affix-on', function(e){
      var next = $(this).next();
      var pdg = parseInt(next.css('padding-top'));
      next.data('padding-top', pdg);
      next.css('padding-top', pdg + $(this).outerHeight());
    });
    $('.group-nav.affixable').on('affix-off', function(e){
      var next = $(this).next();
      var pdg = next.data('padding-top');
      next.css('padding-top', pdg);
    });
  });
})(jQuery, window, document);