;(function ( $, window, document, undefined ) {
  $(function(){
    if($('.top-banner-image').length){
      $('.top-banner-image').parallaxScroll({ rate: .5 });
    }
  });
})(jQuery, window, document);