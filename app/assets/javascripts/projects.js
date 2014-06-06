;(function ( $, window, document, undefined ) {
  $(function(){
    if($('.project-details').length){
      //make top image height of the screen
      var $window     = $(window),
          $topSection   = $('#top-project-section'),
          topHeight = $window.height() - 60;
      $topSection.css('height',topHeight);
      $window.resize(function(){
        topHeight = $window.height() - 60;
        $topSection.css('height',topHeight);
      });
      //trigger to scroll page down
      $('.project-details').on('click','.js-scroll-main-project',function(){
        $('html,body').animate({scrollTop: topHeight+60}, 800);
      });
      //parallax the header
      $('#project-header-in').parallaxScroll({ rate: .3, opacity: true, opacitySpread: 700});
    }

    //make scrollspy/sidebar navigation work
    $('body').scrollspy({ target: '#scroll-nav'});

    $('#project_current.boolean').click(function(e){
      if ($(this).is(':checked')) {
        $('#project_end_date_1i').prop('disabled', true);
        $('#project_end_date_2i').prop('disabled', true);
      } else {
        $('#project_end_date_1i').prop('disabled', false);
        $('#project_end_date_2i').prop('disabled', false);
      }
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

    $('.project').on('mouseenter', '.thumb-image a', function(){
      img = $('img', this);
      targetClass = img.data('target');
      parent = $(this).parent().parent().parent().parent();
      $('.thumb-image img', parent).removeClass('current');
      img.addClass('current');
      target = $('.headline-image-inner.' + targetClass, parent);
      currentHeadline = $('.headline-image-inner:visible', parent);
      if (!currentHeadline.hasClass(targetClass)) {
        currentHeadline.css('z-index', '999');
        target.show();
        currentHeadline
          .hide()
          .css('z-index', '0');
      }
    });

    $('body').on('click', '.image-widget .nav', function(e){
      parent = $(this).parent().parent().parent();
      crtImg = $('.headline-image-inner:visible', parent);
      nextClass = $(this).data('next');
      next = $('.headline-image-inner.' + nextClass, parent);

      crtImg.css('z-index', '999');
      next.show();
      crtImg
        .hide()
        .css('z-index', '0');
      $('.thumb-image img', parent).removeClass('current');
      img = $('.thumb-image-inner img.' + nextClass, parent);
      img.addClass('current');
      scroller = $('.scroller', parent);
      pos =  scroller.scrollLeft() + img.offset().left - scroller.offset().left;
      scroller.scrollLeft(pos);
    });

    $('.widget-form').on('click', '.btn[data-toggle="subcat"]', function(e){
      e.preventDefault();
    });

    $('.widget-form').on('click', '.btn[data-toggle="subcat"]:not(.active)', function(e){
      console.log(this);
      $('.widget-form .btn').removeClass('active');
      $(this).addClass('active');
      $('.widget-form .checkmark').hide();
      $('.widget-form input[type="radio"]').prop('checked', false);
      $target = $($(this).data('target'));
      if ($('.widget-subcategories:visible').length > 0) {
        $('.widget-subcategories:visible').slideUp(function(){
          $target.slideDown();
        });
      } else {
        $target.slideDown();
      }
    });

    $('.widget-form').on('click', '.btn.with-radio', function(e){
      e.preventDefault();
      $('input', $(this)).prop('checked', true);
      $('.widget-form .checkmark').hide();
      $('.widget-form .btn.with-radio').removeClass('active');
      $('.checkmark', $(this)).show();
      $(this).addClass('active');
    });

    $('.widget-form .widget-categories:not(.widget-subcategories)').on('click', '.btn.with-radio', function(e){
      $('.widget-form .btn:not(.with-radio)').removeClass('active');
      $('.widget-form .checkmark').hide();
      $('.widget-subcategories:visible').slideUp();
    });

    // triggers event for class change
    $.each(["addClass","removeClass"],function(i, methodname){
      var oldmethod = $.fn[methodname];
      $.fn[methodname] = function(){
        oldmethod.apply(this, arguments);
        this.trigger("classchange");
        return this;
      }
    });

    /*******************
        EDIT PROJECT
    ********************/
    $projectShowItems   = $('.project-show-item');
    $projectEditItems   = $('.project-edit-item');
    $editProjectBtn     = $('.js-edit-project');
    $saveProjectBtn     = $('.js-save-project');
    $editProjectBtn.on('click',function(e){
      e.preventDefault();
      e.stopPropagation();
      editProject();
    });
    $saveProjectBtn.on('click',function(e){
      e.preventDefault();
      e.stopPropagation();
      saveProject();
    });
    if($('.project-show').length){
      if($('.project-show').data('editmode')){
        editProject();
      }
    }
  });


  /*******************
      EDIT PROJECT
  ********************/
  var $projectShowItems,
      $projectEditItems,
      $editProjectBtn,
      $saveProjectBtn;

  function editProject(){
    $projectShowItems.hide();
    $projectEditItems.fadeIn();
    $editProjectBtn.hide();
    $saveProjectBtn.show();
  }

  function saveProject(){
    //Enter JS to save project fields
    //...
    $projectEditItems.hide();
    $projectShowItems.fadeIn();
    $saveProjectBtn.hide();
    $editProjectBtn.show();
  }


})(jQuery, window, document);

$(window).load(function(){
  $('.image-widget .thumb-image').each(function(i, el){
    total = 0;
    $('.thumb-image-inner img', el).each(function(j, inner){
      total += $(inner).outerWidth();
    });
    parent = $(el).parent().width();
    $(el).width(Math.max(total, parent));
  });
});