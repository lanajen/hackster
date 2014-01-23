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
      smoothScrollTo($target);
    }
  });

  $('body').on('click', 'a.scroll', function(e){
    e.preventDefault();
    target = $($(this).data('target'));
    smoothScrollTo(target);
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
    // $.cookie('thumb-list-style', listType);
    // console.log($.cookie('thumb-list-style'));
  });

  $('.well').on({
    mouseenter: function() {
      $('.btn-delete', this).show();
    }, mouseleave: function() {
      $('.btn-delete', this).hide();
    }
  }, '.comment');

  // make widgets full width
  $('body').on('click', 'a.to-full-width', function(e){
    e.preventDefault();

    target = $($(this).data('target'));
    copy = target.clone();
    copy.attr('id', target.attr('id') + '-copy')
    copy.css({
      position: 'fixed',
      top: target.offset().top - $(window).scrollTop(),
      left: target.offset().left,
      width: target.width(),
      'z-index': 100
    });
    copy.addClass('widget full-width');
    $('.btn-edit', copy).remove();
    $('<a class="btn-edit to-compact" data-target="#' + target.attr('id') + '" data-copy="#' + copy.attr('id') + '" href="#" rel="tooltip" title="Close"><i class="fa fa-compress"></a>').appendTo($('.header h4', copy));
    $('#full-width .background')
      .data('target', '#' + target.attr('id'))
      .data('copy', '#' + copy.attr('id'));
    copy.appendTo($('#full-width .inner-container'));
    $('#full-width').fadeIn(function(){
      $('body').addClass('no-scroll');
    });
    copy.animate({
      top: $('#full-width .inner-container').offset().top - $(window).scrollTop(),
      left: $('#full-width .inner-container').offset().left + 11,
      width: $('#full-width .inner-container').width()
    }, function(){
      copy.attr('style', '');
    });

    if ($('.collapsible', copy).length > 0) {
      tmp = copy
        .clone()
        .css({
          position: 'absolute',
          left: '-100000px'
        })
        .appendTo('body');
      $('.collapsible', tmp).removeClass('collapsed');
      $('.collapsible', tmp).addClass('expanded');
      height = $('.collapsible .highlight pre', tmp).outerHeight();
      tmp.remove();
      $('.collapsible', copy).addClass('expanded');
      $('.collapsible .highlight pre', copy).animate({ 'max-height': height }, function(){
        $('.collapsible', copy).removeClass('collapsed');
      });
    }
  });

  // make widgets normal size
  $('body').on('click', '.to-compact', function(e){
    e.preventDefault();

    copy = $($(this).data('copy'));
    target = $($(this).data('target'));
    copy.css({
      position: 'fixed',
      top: copy.offset().top - $(window).scrollTop(),
      left: copy.offset().left,
      width: copy.outerWidth(),
      'z-index': 100
    });
    if ($('.collapsible', copy).length > 0) {
      $('.collapsible', copy).removeClass('expanded');
      $('.collapsible .highlight pre', copy).animate({ 'max-height': '150px' }, function(){
        $('.collapsible', copy).addClass('collapsed');
      });
    }
    copy.animate({
      top: target.offset().top - $(window).scrollTop(),
      left: target.offset().left,
      width: target.width(),
    }, function(){
      copy.remove();
    });
    $('#full-width').fadeOut(function(){
      $('body').removeClass('no-scroll');
    });
  });
});