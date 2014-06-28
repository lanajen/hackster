;(function ( $, window, document, undefined ) {
  $(function(){
    if($('#top-bg-image').length){
      $('#top-bg-image').parallaxScroll({ rate: .5 });
    }
  });
})(jQuery, window, document);