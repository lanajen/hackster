function checkIfCommentsHaveSameDepthYoungerSiblings() {
  var previousCommentClass;
  var els = [];
  $.each($('.single-comment').get().reverse(), function(i, el){
    if (previousCommentClass == el.className) els.push(el);
    previousCommentClass = el.className;
  });
  $.each(els, function(i, el){
    $(el).addClass('has-same-depth-younger-sibling');
  });
}

;(function ( $, window, document, undefined ) {
  $(function(){
    $('.show-simplified-signup').click(function(e){
      e.preventDefault();
      $('#simplified-signup-popup input[name="redirect_to"]').val($(this).data('redirect-to'));
      $('#simplified-signup-popup input[name="source"]').val($(this).data('source'));
      openModal('#simplified-signup-popup');
    });

    // if($('#top-project-section').length){
    //   //make top image height of the screen
    //   var $window     = $(window),
    //       $topSection = $('#top-project-section'),
    //       topHeight   = $window.height() - $topSection.offset().top;
    //   $topSection.css('height',topHeight);
    //   $window.resize(function(){
    //     topHeight = $window.height() - $topSection.offset().top;
    //     $topSection.css('height',topHeight);
    //   });
    //   //trigger to scroll page down
    //   $('.project-details').on('click','.js-scroll-main-project',function(){
    //     $('html,body').animate({scrollTop: $window.height()}, 800);
    //   });
    //   //parallax the header
    //   $('#project-header-in').parallaxScroll({ rate: .3, opacity: true, opacitySpread: 700});
    // }

    $('.title-toggle').on('click', function(e){
      e.preventDefault();
      $(this).parent().next().slideToggle(150);
      $(this).closest('.section-collapsible').toggleClass('section-toggled');
    })

    //make scrollspy/sidebar navigation work
    $('body').scrollspy({ target: '#scroll-nav'});

    // $('body').on('click', 'a.expand', function(e){
    //   e.preventDefault();
    //   target = $(this).data('target');
    //   $target = $(target);
    //   $target.toggleClass('collapsed');
    //   $target.slideToggle();
    //   if (!$target.hasClass('collapsed')) {
    //     smoothScrollTo($target);
    //   }
    // });

    $('body').on('click', 'a.scroll', function(e){
      e.preventDefault();
      target = $($(this).data('target'));
      offsetTop = $(this).data('offset') || 0;
      smoothScrollTo(target,offsetTop);
    });

    $('body').on('click', '.comment-reply', function(e){
      e.preventDefault();
      target = $($(this).data('target'));
      target.slideToggle();
    });

    $('body').on('click', '.new-comment input[type="submit"]', function(e){
      $(this).parent().parent().submit();
      $(this).replaceWith('<i class="fa fa-spin fa-spinner"></i>');
    });

    checkIfCommentsHaveSameDepthYoungerSiblings();

    // triggers event for class change
    $.each(["addClass","removeClass"],function(i, methodname){
      var oldmethod = $.fn[methodname];
      $.fn[methodname] = function(){
        oldmethod.apply(this, arguments);
        this.trigger("classchange");
        return this;
      }
    });

    // var delayOut = 500,
    //     delayIn = 200,
    //     setTimeoutConstIn = {},
    //     setTimeoutConstOut = {};

    // $('.platform-card-popover').hover(function(e){
    //   clearTimeout(setTimeoutConstOut[$(this).data('target')]);
    //   var that = this;
    //   setTimeoutConstIn[$(this).data('target')] = setTimeout(function(){
    //     var target = $($(that).data('target'));
    //     var x = $(that).offset().left;
    //     if ((x + target.outerWidth()) > window.innerWidth) {
    //       x = $(that).offset().left + $(that).width() - target.outerWidth();
    //     }
    //     var y = $(that).offset().top + $(that).outerHeight() + 3;
    //     var $window = $(window);
    //     if ((y + target.outerHeight()) > ($window.scrollTop() + $window.height())) {
    //       y = $(that).offset().top - target.outerHeight() - 3;
    //     }
    //     target.css('top', y + 'px');
    //     target.css('left', x + 'px');
    //     $('.platform-card').hide();
    //     target.fadeIn(100);
    //   }, delayIn);
    // }, function(e){
    //   clearTimeout(setTimeoutConstIn[$(this).data('target')]);
    //   var target = $($(this).data('target'));
    //   setTimeoutConstOut[$(this).data('target')] = setTimeout(function(){
    //     target.fadeOut(100);
    //   }, delayOut);
    // });

    // $('.platform-card').hover(function(e){
    //   clearTimeout(setTimeoutConstOut['#' + $(this).attr('id')]);
    // }, function(e){
    //   var that = this;
    //   setTimeoutConstOut['#' + $(this).attr('id')] = setTimeout(function(){
    //     $(that).fadeOut(100);
    //   }, delayOut);
    // });

    $serializedForm = null;
    $formContent = {};

    var pe = {
      serializeForm: function() {
        $('.pe-panel:visible form.remote').find('input:not([type="checkbox"])').each(function(){
          // be as specific as possible so that fields with the same name don't collide
          $formContent['[name="' + $(this).attr('name') + '"][type="' + $(this).attr('type') + '"]'] = $(this).val();
        });
        $('.pe-panel:visible form.remote').find('textarea, select').each(function(){
          $formContent['[name="' + $(this).attr('name') + '"]'] = $(this).val();
        });

        // handle checkboxes since they don't react to val() the same way
        $('.pe-panel:visible form.remote').find('input[type="checkbox"]').each(function(){
          $formContent['[name="' + $(this).attr('name') + '"][type="checkbox"][value="' + $(this).val() + '"]'] = $(this).prop('checked');
        });

        $serializedForm = $('.pe-panel:visible form.remote').serialize();
      },

      unsavedChanges: function() {
        return ($serializedForm != $('.pe-panel:visible form.remote').serialize());
      },

      resizePeContainer: function() {
        $('.pe-container').height($('.pe-panel:visible').outerHeight());
        // console.log('resize!');
      },

      discardChanges: function() {
        if ($serializedForm != null) {
          $.each($formContent, function(selector, val) {
            var input = $('.pe-panel:visible form.remote').find(selector);
            // handle checkboxes since they don't react to val() the same way
            if (selector.indexOf('[type="checkbox"]') != -1) {
              input.prop('checked', val);
            } else {
              input.val(val);

              // for select2 inputs
              if (input.length > 1) {
                // because select2 automatically adds a hidden input
                input.each(function(i, el){
                  if ($(el).is('select') && typeof($(el).data('select2')) != 'undefined') {
                    $(el).trigger('change');
                  }
                });
              } else if (input.hasClass('select2')) {
                input.trigger('change');
              }
            }
          });
          $('.inserted').remove();
          $('.fields.added').remove();
          $('.fields.removed').show().removeClass('removed');

          this.serializeForm();
        }
      },

      showEditorTab: function(tab) {
        var _ = this;

        // console.log("showing " + tab);

        // discardChanges();

        // hide the medium media bar
        $('.medium-media-menu').hide().find('.media-menu-btns').removeClass('is-open');
        // hide discard button if story
        if (tab == '#story') {
          $('.pe-discard').hide();
        } else {
          $('.pe-discard').show();
        }

        $('.pe-save').slideUp(200);

        $('.pe-nav a').removeClass('active');
        $(tab + '-nav').addClass('active');

        var target = $(tab);
        $('.pe-panel:visible').removeResize();
        $('.pe-panel').hide();

        target.fadeIn(100, function(){
          if (tab == '#story') {
            $('.pe-discard').hide();
            $.each(codeEditor, function(i, el) {
              heightUpdateFunction("#code-editor-" + el.id, el.ace);
            });
          }
          if (tab == '#story') {
            loadSlickSlider();
          }
          target.resize(function(){ _.resizePeContainer() });
        });

        _.serializeForm();

        window.scroll(0, 0);  // so it doesn't scroll to the div
      },

      saveChanges: function() {
        if ($('#story:visible').length) {
          editor.forceSaveModel();
        }
        $('.pe-panel:visible form.remote').submit();
      },

      reload: function() {
        var form = $('.pe-panel:visible form.remote');
        form.find('input[name=save]').val('0');
        form.submit();
      }
    }

    window.pe = pe;

    $('.pe-panel:visible').resize(function(){ pe.resizePeContainer() });
    pe.serializeForm();

    $('.pe-nav').on('click', 'a.tab', function(e){
      if (window.location.hash == $(this).attr('href')) {
        e.preventDefault();
      } else if (pe.unsavedChanges()) {
        var c = confirm("There are unsaved changes\nAre you sure you want to move away?");
        if (c == true) {
          pe.discardChanges();
        } else {
          e.preventDefault();
        }
      }
    });

    if (window.location.pathname.match(/\/projects\/[0-9]+\/edit/) != null) {
      if (hash = window.location.hash) {
        pe.showEditorTab(hash);
      }
      $(window).bind('hashchange', function() {
        pe.showEditorTab(window.location.hash);
      });
    }

    $('.pe-panel')
      .on("ajax:beforeSend", 'form.remote', function(xhr, settings){
        $('.pe-save').slideUp(200);
        $('.pe-error').hide();
        $(this).closest('.pe-container').addClass('processing');
      })
      .on('ajax:complete', 'form.remote', function(xhr, status){
        $(this).closest('.pe-container').removeClass('processing');
      })
      .on('ajax:error', 'form.remote', function(xhr, status){
        $('.pe-save').slideDown(200);
        $('.pe-error').show();
      })
      .on('ajax:success', 'form.remote', function(xhr, status){
        pe.serializeForm();
        $('.fields.added').removeClass('added');
        $('.fields.removed').remove();
      });

    $('.pe-submit').on('click', function(e){
      e.preventDefault();
      pe.saveChanges();
    });

    $('.pe-panel').on('input change', 'form, input, textarea, select', function(e){
      $('.pe-save').slideDown(200);
    });

    $('.pe-discard').on('click', function(e){
      e.preventDefault();

      pe.discardChanges();
      $('.pe-save').slideUp(200);
    });

    $('.pe-panel form').on('nested:fieldAdded', function(e){
      e.field.addClass('added');
      $(this).trigger('change');
    });

    $('.pe-panel form').on('nested:fieldRemoved', function(e){
      e.field.addClass('removed');
      $(this).trigger('change');
    });

    window.addEventListener("beforeunload", function (e) {
      if (pe.unsavedChanges()) {
        var message = "There are unsaved changes.";

        (e || window.event).returnValue = message;
        return message;
      }
    });

    loadSlickSlider();
  });
})(jQuery, window, document);

function ProjectCodeEditor(language, id) {
  this.ace = null;
  this.isActive = false;
  this.language = language;
  this.id = id;
}

ProjectCodeEditor.prototype.activate = function() {
  this.ace = ace.edit("code-editor-"  + this.id);
  this.ace.setTheme("ace/theme/idle_fingers");
  this.ace.getSession().setMode("ace/mode/" + this.language);
  this.ace.getSession().setUseSoftTabs(true);
  this.ace.setShowPrintMargin(false);
  this.ace.getSession().setTabSize(2);
  this.ace.renderer.setPadding(10);
  this.ace.renderer.setScrollMargin(10, 10, 0, 0);
  this.ace.getSession().setUseWrapMode(true);

  // Set initial size to match initial content
  cEditorUpdateHeight("#code-editor-" + this.id, this.ace);

  // Whenever a change happens inside the ACE editor, update
  // the size again
  var _ = this;
  this.ace.getSession().on('change', function(e){
    cEditorUpdateHeight("#code-editor-" + _.id, _.ace);
  });

  this.isActive = true;
}

function cEditorUpdateHeight(div, cEditor) {
  // http://stackoverflow.com/questions/11584061/
  var newHeight =
    cEditor.getSession().getScreenLength()
    * cEditor.renderer.lineHeight
    + cEditor.renderer.scrollBar.getWidth()
    + 20;  // padding

  $(div).height(newHeight);
  $(div).parent('.code-editor-container').height(newHeight);

  // This call is required for the editor to fix all of
  // its inner structure for adapting to a change in size
  cEditor.resize();
}

function loadSlickSlider(){
  $('.image-gallery:visible:not(.slick-initialized)').slick({
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