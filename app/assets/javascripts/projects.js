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

(function ($, window, document, undefined) {
  $(function() {
    $('#simplified-signup-popup').on('modal:open', function(e){
      $(this).find('#user_email').focus();
    });
    $('.show-simplified-signup').on('click', function(e) {
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

    $('body').on('click', 'a.scroll', function(e){
      e.preventDefault();
      target = $($(this).data('target'));
      offsetTop = $(this).data('offset') || 0;
      smoothScrollTo(target,offsetTop);
    });

    $('body').on('click', '.comment-reply', function(e){
      e.preventDefault();
      target = $($(this).data('target'));
      if (target.is(':visible')) {
        scrollToComment(target);
      } else {
        target.slideToggle(100, function(){
          scrollToComment(target);
        });
      }
    });

    function scrollToComment(target) {
      var x = window.scrollX, y = window.scrollY;
      target.find('textarea').focus();
      window.scrollTo(x, y);  // prevent focus() scroll so we can do it smoothly
      if (target.offset().top > $(window).height() + $(window).scrollTop()) {
        smoothScrollToBottom(target, 20);
      }
    }

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
          $('form.sortable .table-sortable tbody').sortable('cancel');

          $('.form-group .error-message').remove();
          $('.form-group').removeClass('has-error');
          $('.pe-error').hide();

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

        $('.pe-save2').show();
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
          // $('#project_description').html(editor.self.serialize()['element-0'].description);
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
        $('.pe-save2').show();
        $('.pe-error').hide();
        $(this).closest('.pe-container').addClass('processing');
      })
      .on('ajax:complete', 'form.remote', function(xhr, status){
        $(this).closest('.pe-container').removeClass('processing');
        sortTable();
      })
      .on('ajax:error', 'form.remote', function(xhr, status){
        $('.pe-save').slideDown(200);
        $('.pe-save2').hide();
        $('.pe-error').show();
      })
      .on('ajax:success', 'form.remote', function(xhr, status){
        if ($('#story:visible').length) {
          editor.unsavedChanges = false;
        }
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
      $('.pe-save2').hide();
    });

    $('.pe-discard').on('click', function(e){
      e.preventDefault();

      pe.discardChanges();
      $('.pe-save').slideUp(200);
      $('.pe-save2').show();
    });

    $('.pe-panel form').on('nested:fieldAdded', function(e){
      e.field.addClass('added');
      $(this).trigger('change');
    });

    $('.pe-panel form').on('nested:fieldRemoved', function(e){
      e.field.addClass('removed');
      $(this).trigger('change');
    });

    $('#basics').on('change', '[name="project[cover_image_id]"]', function(e){
      $('.pe-save').slideDown(200);
      $('.pe-save2').hide();
    });

    // event methods for software/hardware
    $('.modal-with-form')
      .on('click', '.select-file', function(e){
        e.preventDefault();

        var form = $($(this).data('form'));
        form.find('input:file').click();
      })
      .on('modal:closed', function(){
        $(this).find('.has-error .help-block.error-message').remove();
        $(this).find('.form-group').removeClass('has-error');
      });

    $('.form-within-modal')
      .on('ajax:beforeSend', function(xhr, settings){
        $('.error-notif').remove();
      })
      .on('ajax:success', function(xhr, data, status){
        closeModal($(this).data('modal'));
        pe.reload();
      })
      .on('ajax:error', function(error, xhr, status){
        error.stopPropagation();

        var $form = $(this),
            errors,
            errorText;

        try {
          // Populate errorText with the comment errors
          errors = $.parseJSON(xhr.responseText);
        } catch(err) {
          // If the responseText is not valid JSON (like if a 500 exception was thrown), populate errors with a generic error message.
          errors = {message: "Please reload the page and try again"};
        }

        // cleanup before adding new elements
        $(this).find('.has-error .help-block.error-message').remove();
        $(this).find('.form-group').removeClass('has-error');
        var errorFields = [];

        // make it work for nested attributes in this specific case
        for (model in errors) {
          for (attribute in errors[model]) {
            // transforms attribute name for nested attributes
            var attrName = attribute;
            if (attribute.indexOf('.') != -1) {
              var attributes = attribute.split('.');
              attribute = attributes[attributes.length - 1];
            }
            var input = $form.find('[name$="['+attribute+']"]');
            var labelText = input.parent().find('label').text().replace('* ', '');
            errorFields.push(labelText);
            input.parents('.form-group').addClass('has-error');
            errorMsg = $('<span class="help-block error-message">' + errors[model][attrName] + '</span>');
            if (input.parent().hasClass('input-group')) {
              errorMsg.insertAfter(input.parent());
            } else {
              errorMsg.insertAfter(input);
            }
          }
        }
        var notif = $('<div class="text-danger error-notif" style="margin:20px 0;">Oops, check for errors above (' + errorFields.join(', ') + ').</div>');
        $(this).find('input[name="commit"]').before(notif);
      });

    $('#code-editor-popup').on('modal:opening', function(){
      cEditor.ace.setValue($(this).find('[data-field-type="raw_code"]').val());
      cEditor.ace.selection.clearSelection();
      var lang = $(this).find('[data-field-type="language"]').val();
      if (lang == '') lang = 'text';
      cEditor.ace.getSession().setMode("ace/mode/" + lang);
    });

    $('#code-editor-popup').on('modal:open', function(){
      cEditorUpdateHeight('#code-editor-0', cEditor.ace);
    });

    $('#code-editor-popup').on('change', '[data-field-type="language"]', function(e){
      var lang = $(this).val();
      if (lang == '') lang = 'text';
      cEditor.ace.getSession().setMode("ace/mode/" + lang);
    });

    $('#code-editor-popup').on('click', '.upload-code', function(e){
      e.preventDefault();

      $('#code-upload-form input').click();
    });

    $('.pe-panel').on('click', '.modal-reset', function(e){
      var target = $($(this).data('target'));
      target.find('.resetable').val('');
      var type = $(this).data('field-type');
      if (type)
        target.find('[data-field-type=type]').val(type);
    });

    $('.pe-panel').on('click', '.edit-in-modal', function(e){
      e.preventDefault();
      var popup = $(this).data('modal');
      var inputs = $(this).closest('.fields').find('input[type=hidden], textarea.hidden');
      inputs.each(function(i, el){
        var input = $(popup).find('[data-field-type="' + $(el).data('field-type') + '"]');
        input.val($(el).val());
      });
      openModal(popup);
    });

    $(document).on('click', '.goto', function(e){
      e.preventDefault();

      var target = $(this).data('target');
      var anchor = $('[data-anchor="' + target + '"]');
      if (anchor.length) {
        var id = anchor.closest('.pe-panel').attr('id');
        window.location.hash = '#' + id;
        // give it time to change tab before scrolling down
        window.setTimeout(function(){
          smoothScrollToAndHighlight(anchor, null, anchor);
        },1);
      }
    });

    $("#code-upload-form").fileupload({
      dataType: 'json',
      limitMultifileUploads: 1,
      sequentialUploads: true,
      limitConcurrentUploads: 1,

      add: function(e, data) {
        fileName = data.files[0].name;
        ext = fileName.substr(fileName.lastIndexOf('.') + 1);
        if($.inArray(ext, ['gif','png','jpg','jpeg']) != -1) {
          $(".code-upload-progress-container").html("<p>Images are not allowed. You can only upload files that contain code.</p>");
          return;
        }
        tpl = $('<p class="progress-legend">Uploading...</p><div class="progress progress-striped active"><div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width:0%;">');
        $(".code-upload-progress-container").html(tpl);
        data.context = tpl;
        data.submit();
      },

      fail: function(e, data){
        data.context.fadeOut(200, function(){
          $(this).remove();
        });
        $(".code-upload-progress-container").html('<p>Error uploading ' + data.files[0].name + '.</p>');
        //showErrorBubble(data.files[0].name);
      },

      progress: function(e, data) {
        progress = parseInt(data.loaded / data.total * 100, 10);
        target = data.context.find('.progress-bar');
        target.css('width', progress + '%');
        if (progress == 100) {
          target.addClass('progress-bar-success');
        }
      },

      success: function(data) {
        cEditor.ace.setValue(data.raw_code);
        cEditor.ace.selection.clearSelection();
        if ($('#code-editor-popup [data-field-type="name"]').val() == '')
          $('#code-editor-popup [data-field-type="name"]').val(data.name);
        if ($('#code-editor-popup [data-field-type="language"]').val() == '')
          $('#code-editor-popup [data-field-type="language"]').val(data.language);
        $('#code-editor-popup [data-field-type="document_id"]').val(data.document_id);
      },

      done: function(e, data){
        data.context.fadeOut(200, function(){
          $(this).remove();
        });
      }
    });

    $('#file-upload-form').fileupload({
      dataType: 'xml', // This is really important as s3 gives us back the url of the file in a XML document
      limitMultifileUploads: 1,
      sequentialUploads: true,
      limitConcurrentUploads: 1,
      fileInput: $('#file-upload-form input:file'),
      dropZone: $('#file-upload-form'),

      add: function(e, data) {
        file = data.files[0];
        tpl = $('<p class="progress-legend">Uploading...</p><div class="progress progress-striped active"><div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width:0%;">');
        $(".file-upload-progress-container").html(tpl);
        data.context = tpl;

        var form = $(this);
        var _data = data;
        data.context.data('data', data);

        $.ajax({
          url: '/files/signed_url',
          type: 'GET',
          dataType: 'json',
          data: { file: {name: file.name}, context: 'no-context' },
          success: function(data) {
            form.find('input[name=key]').val(data.key);
            form.find('input[name=policy]').val(data.policy);
            form.find('input[name=signature]').val(data.signature);
            _data.submit();
          },
          error: function(data) {
            context = decodeURIComponent($.urlParam(this.url, 'context'));
            handleUploadErrors($('#' + context));
          }
        });
      },

      fail: function(e, data){
        data.context.fadeOut(200, function(){
          $(this).remove();
        });
        $(".code-upload-progress-container").html('<p>Error uploading ' + data.files[0].name + '.</p>');
      },

      progress: function(e, data) {
        progress = parseInt(data.loaded / data.total * 100, 10);
        target = data.context.find('.progress-bar');
        target.css('width', progress + '%');
        if (progress == 100) {
          target.addClass('progress-bar-success');
        }
      },

      success: function(data) {
        var url = $(data).find('Location').text(); // or Key for path
        form = $('#file-upload-form');
        form.attr('data-url', url);  // pass it to 'done'
      },

      done: function(e, data){
        var _data = data;

        data.context.data('data', data);

        form = $('#file-upload-form');
        form.data('data', data);
        url = form.attr('data-url');

        $.ajax({
          url: '/files',
          type: 'POST',
          dataType: 'json',
          data: {
            file_url: url,
            file_type: 'document',
            context: 'no-context'
          },
          success: function(data) {
            $('[data-field-type=document_file_name]').val(data.file_name);
            $('[data-field-type=document_id]').val(data.id);
            _data.context.remove();
          },
          error: function(data) {
            context = decodeURIComponent($.urlParam(this.data, 'context'));
            handleUploadErrors($('#' + context));
          }
        });
      }
    });

    $('.admin-bar .toggle-checklist').on('click', function(e){
      e.preventDefault();
      $('.admin-bar #checklist').toggle();
    });

    window.addEventListener("beforeunload", function (e) {
      if (pe.unsavedChanges()) {
        var message = "There are unsaved changes.";

        (e || window.event).returnValue = message;
        return message;
      }
    });

    $('.gist').gist();
    window.setTimeout(function(){
      $('.gist .gist-meta a').attr('target', '_blank');
    }, 1000);

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