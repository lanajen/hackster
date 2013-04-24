$(document).ready(function(){
  $('.project .image-thumbs img').live('mouseenter', function(){
    targetClass = $(this).data('target');
    parent = $(this).parent().parent();
    target = $('.headline-image img.' + targetClass, parent);
    currentHeadline = $('.headline-image img:visible', parent);
    if (!currentHeadline.hasClass(targetClass)) {
      currentHeadline.css('z-index', '999');
      target.show();
      currentHeadline.fadeOut(150, function(){
        $(this).css('z-index', '0');
      });
    }
  });

  $('#project_current.boolean').click(function(e){
    if ($(this).is(':checked')) {
      $('#project_end_date_1i').prop('disabled', true);
      $('#project_end_date_2i').prop('disabled', true);
    } else {
      $('#project_end_date_1i').prop('disabled', false);
      $('#project_end_date_2i').prop('disabled', false);
    }
  });
});