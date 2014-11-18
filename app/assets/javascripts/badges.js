$(function () {
  var badgeTimer;
  if ($('#badge-alert').length) {
    window.setTimeout(function(){
      showBadgeAlert();
    }, 2000);
  }

  $('body').on('click', '#badge-alert .close', function(e){
    $('#badge-alert').fadeOut(200, function(){
      $(this).remove();
    });
  });

  $(document).ajaxComplete(function(event, request) {
    var badgeHtml = request.getResponseHeader('X-New-Badge');

    if (typeof(badgeHtml) != undefined) {
      if ($('#badge-alert').length){
        $badgeHtml = badgeHtml;
          $('#badge-alert').remove(function(){
            showBadgeAlert($badgeHtml);
          });

      //   });
      } else {
        showBadgeAlert(badgeHtml);
      }
    }
  });

  function showBadgeAlert(badgeHtml) {
    if (typeof(badgeHtml) != undefined) $(badgeHtml).appendTo('body');

    $('#badge-alert').fadeIn(300);
  }

  $('body').on('click', '#badge-alert', function(){
    $(this).fadeOut(200, function(){
      $(this).remove();
    });
  }).children('a').on('click', function(e){
    e.stopPropagation();
  });
});