$(document).ready(function(){
  $('.project').on('mouseenter', '.image-thumbs li', function(){
    img = $('img', this);
    targetClass = img.data('target');
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

  $('.well').on('keypress', '#new_comment textarea',function(){
    if (event.which == 13 && !event.shiftKey) {
      event.preventDefault();
      $(this).parents('form').submit();
    }
  });

  // auto adjust the height of
  $('.well').on('keyup keydown', '#new_comment textarea',function(){
    var t=$(this);
    t.height(15).height(t[0].scrollHeight);//where 15 is minimum height of textarea
  });

  $('body').on('click', 'a.expand', function(e){
    e.preventDefault();
    target = $(this).data('target');
    $target = $(target);
    $target.toggleClass('collapsed');
    $target.slideToggle();
    if (!$target.hasClass('collapsed')) {
      $('html, body').stop().animate({
          'scrollTop': $target.offset().top
      }, 500, 'swing', function () {});
    }
  });

  $('.well').on({
    mouseenter: function() {
      $('.btn-delete', this).show();
    }, mouseleave: function() {
      $('.btn-delete', this).hide();
    }
  }, '.comment');
});