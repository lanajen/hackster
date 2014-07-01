$(){
  // Set up mobile nav menu/trigger
  var $outerWrapper = $('#outer-wrapper'),
      $moNavOverlay = $('#mobile-nav-overlay'),
      $moNav        = $('#mobile-navigation');
  $('#nav-mobile-trigger').on('click',function(){
    $outerWrapper.addClass('mobile-nav-open');
    $moNavOverlay.show();
    setTimeout(function(){
      $moNavOverlay.addClass('showing');
      $moNav.addClass('showing');
    },1);
  });
  $moNavOverlay.on('click',function(){
    $moNavOverlay.removeClass('showing');
    $moNav.removeClass('showing');
    $outerWrapper.removeClass('mobile-nav-open');
    setTimeout(function(){
      $moNavOverlay.hide();
    },500);
  });
}