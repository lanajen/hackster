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

$select2containers = {};
$select2target = null;

// Polyfill for IE.  https://developer.mozilla.org/en-US/docs/Web/API/CustomEvent/CustomEvent
(function () {
  function CustomEvent ( event, params ) {
    params = params || { bubbles: false, cancelable: false, detail: undefined };
    var evt = document.createEvent( 'CustomEvent' );
    evt.initCustomEvent( event, params.bubbles, params.cancelable, params.detail );
    return evt;
   }

  CustomEvent.prototype = window.Event.prototype;

  window.CustomEvent = CustomEvent;
})();

(function ($, window, document, undefined) {
  $(function() {
    $('.project-page-single-column').resize(function(){
      updatedScrollEventHandlers();
    });

    $('.show-simplified-signup').on('click', function(e) {
      e.preventDefault();
      var redirLink = $(this).data('redirect-to');
      $('#simplified-signup-popup input[name="redirect_to"]').val(redirLink);
      $('#simplified-signup-popup input[name="source"]').val($(this).data('source'));

      if ($(this).hasClass('with-name')) {
        $('#simplified-signup-popup .full-name-wrapper').show();
      }

      var signInHref = $('#simplified-signup-popup .sign-in-link');
      var signInLink = signInHref.attr('href');
      signInLink += '?redirect_to=' + encodeURIComponent(redirLink);
      signInHref.attr('href', signInLink);

      openModal('#simplified-signup-popup');
    });

    $('#simplified-signup-popup').on('modal:open', function(e){
      if ($(this).find('input[name="user[full_name]"]:visible').length) {
        $(this).find('input[name="user[full_name]"]').focus();
      } else {
        $(this).find('#user_email').focus();
      }
    });

    $('.show-all-projects-form input[type=checkbox]').on('change', function(e){
      var form = $('.show-all-projects-form');
      if (!$(this).prop('checked'))
        form.append('<input type="hidden" name="show_all" value="1"/>');
      form.submit();
    });

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
      var form = $(this).closest('form')
      if (form.hasClass('remote')) {
        $(this).replaceWith('<i class="fa fa-spin fa-spinner"></i>');
        form.submit();
      }
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
                  } else {
                    $(el).val('');
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

        var target = $(tab);
        if (target.length) {
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

          $('.pe-panel:visible').removeResize();
          $('.pe-panel').hide();

          target.fadeIn(100, function(){
            if (tab == '#story') {
              $('.pe-discard').hide();
            }
            target.resize(function(){ _.resizePeContainer() });
          });

          _.serializeForm();

          //window.scroll(0, 0);  // so it doesn't scroll to the div
        }
      },

      showSavePanel: function() {
        $('.pe-save2').hide();
        $('.pe-save').slideDown(200);
      },

      saveChanges: function(e) {
        var $form = $('.pe-panel:visible form.remote');
        if ($('#story:visible').length) {
          // Custom Event passes the form to React.
          var event = new CustomEvent(
            'pe:submit',
            {
              detail: { form: $form },
              bubbles: false,
              cancelable: true
            }
          );
          $form[0].dispatchEvent(event);
        } else {
          // Protip form needs seperation; React component handles posting the submit.
          if ($('.description-form').length) {
            var $dForm = $('.description-form');
            var event = new CustomEvent(
              'pe:submit',
              {
                detail: { form: $dForm },
                bubbles: false,
                cancelable: true
              }
            );
            $dForm[0].dispatchEvent(event);
          }
          // Remove the description form from the $form array (all forms on page).
          $form = $form.filter(function(index, f) {
            return !f.classList.contains('description-form');
          });

          $form.submit();
        }
      },

      reload: function() {
        var form = $('.pe-panel:visible form.remote');
        form.find('input[name=save]').val('0');
        form.submit();
      },

      updateChecklist: function() {
        var form = $('.pe-panel form.remote:first');
        var url = form.attr('action');
        Utils.getApiToken(function(token){
          $.ajax({
            url: url + '.js',
            data: { save: false, panel: 'checklist' },
            method: 'PATCH',
            dataType: 'script',
            headers: {
              'Authorization': 'Bearer ' + token
            }
          });
        })
      }
    }

    window.pe = pe;

    $('.pe-panel:visible').resize(function(){ pe.resizePeContainer() });
    pe.serializeForm();

    $('.pe-nav').on('click', 'a', function(e){
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
      } else {
        pe.showEditorTab('#basics');
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

        // Custom event for React component.
        var $form = $('.story-form');
        if ($form.length) {
          var event = new CustomEvent(
              'pe:complete',
              {
                detail: { form: $form[0] },
                bubbles: false,
                cancelable: true
              }
            );
          $form[0].dispatchEvent(event);
        }

        sortTable();
        $(this).trigger('pe:loaded');
      })
      .on('ajax:error', 'form.remote', function(xhr, status){
        $('.pe-save').slideDown(200);
        $('.pe-save2').hide();
        $('.pe-error').show();
      })
      .on('ajax:success', 'form.remote', function(xhr, status){
        pe.serializeForm();
        $('.fields.added').removeClass('added');
        $('.fields.removed').remove();
        var nextTab = $('.pe-container').data('next-tab');
        if (nextTab)
          window.location.hash = nextTab.replace('#', '');
      });

    $('.pe-submit').on('click', function(e){
      e.preventDefault();
      $('.pe-container').data('next-tab', null);
      if ($(this).hasClass('next')) {
        var id = $('.pe-panel:visible').attr('id');
        var a = $('.pe-nav a[href="#' + id + '"]').parent().next().find('a');
        $('.pe-container').data('next-tab', a.attr('href'));
      }
      pe.saveChanges(e);
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

    $('#basics').on('change', '[name="base_article[cover_image_id]"]', function(e){
      $('.pe-save').slideDown(200);
      $('.pe-save2').hide();
    });

    // handles save on ctrl+s
    if ($('.pe-save').length) {
      $(window).bind('keydown', function(e) {
        if (e.ctrlKey || e.metaKey) {
          if (String.fromCharCode(e.which).toLowerCase() == 's') {
            e.preventDefault();
            // check if we're on a modal form and if so save it, otherwise save pe
            if ($('form.form-within-modal:visible').length) {
              $('form.form-within-modal:visible').submit();
            } else {
              pe.saveChanges();
            }
          }
        }
      });
    }

    // event methods for software/hardware
    $('.modal-with-form')
      .on('click', '.select-file', function(e){
        e.preventDefault();

        var form = $($(this).data('form'));
        form.find('input:file').click();
      })
      .on('modal:closed', function(){
        $(this).find('.error-notif').remove();
        $(this).find('.has-error .help-block.error-message').remove();
        $(this).find('.form-group').removeClass('has-error');
      });

    $('.form-within-modal')
      .on('ajax:beforeSend', function(xhr, settings){
        $('.error-notif').remove();
      })
      .on('ajax:success', function(xhr, data, status){
        closeModal($(this).data('modal'));
        if (!$(this).hasClass('no-reload')) pe.reload();
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

        var msg;
        if (errors.message) {
          msg = errors.message;
        } else {
          msg = 'Oops, check for errors above (' + errorFields.join(', ') + ').';
        }
        var notif = $('<div class="text-danger error-notif" style="margin:20px 0;">' + msg + '</div>');
        $(this).find('input[name="commit"]').before(notif);
      });

    $('#code-editor-popup').on('modal:opening', function(){
      cEditor.ace.setValue($(this).find('[data-field-type="raw_code"]').val());
      cEditor.ace.selection.clearSelection();
      var lang = $(this).find('[data-field-type="language"]').val();
      updateEditorMode(cEditor, lang);
    });

    $('#code-editor-popup').on('modal:open', function(){
      cEditorUpdateHeight('#code-editor-0', cEditor.ace);
    });

    $('#code-editor-popup').on('change', '[data-field-type="language"]', function(e){
      var lang = $(this).val();
      updateEditorMode(cEditor, lang);
    });

    function updateEditorMode(editor, lang) {
      switch (lang) {
        // default if empty
        case '':
          lang = 'text';
          break;
        // ace doesn't have an arduino mode and C/C++ is good enough
        case 'arduino':
          lang = 'c_cpp';
          break;
      }
      editor.ace.getSession().setMode("ace/mode/" + lang);
    }

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

    $('body').on('click', '.edit-in-modal', function(e){
      e.preventDefault();
      var popup = $(this).data('modal');
      if ($('.select2-container--open').length) {
        var parent = $('.select2-container--open');
      } else {
        var parent = $(this);
      }
      var inputs = parent.closest('.fields').find('input[type=hidden], textarea.hidden');
      inputs.each(function(i, el){
        var input = $(popup).find('[data-field-type="' + $(el).data('field-type') + '"]');
        if (input.length)
          input.val($(el).val());
      });
      openModal(popup, this);
    });

    $('body').on('modal:open', '.modal-focus-input', function(e){
      var input = $(this).find('select:visible, input:visible, textarea:visible').first();
      if (input.length) {
        input.focus();
      }
    });

    var select2Options = function(partType) {
      return {
        minimumInputLength: 3,
        ajax: {
          url: Utils.getApiPath() + "/v2/parts",
          dataType: 'json',
          delay: 150,
          transport: function(params, success, failure) {
            Utils.getApiToken(function(token) {
              params.beforeSend = function(request) {
                request.setRequestHeader('Authorization', 'Bearer ' + token);
              }

              var $request = $.ajax(params);

              $request.then(success);
              $request.fail(failure);

              return $request;
            });
          },
          data: function (params) {
            return {
              q: params.term,  // search term
              page: params.page,
              type: partType,
              all_platforms: true
            };
          },
          processResults: function (data, page) {
            var results = _.map(data.parts, function(el){
              return {
                id: el.id,
                part: el
              }
            });
            var extra = { disabled: true, q: data.q, type: data.type };
            if (results.length) {
              extra.id = -1;
              results.push(extra);
            } else {
              extra.id = -2;
              results = [extra];
            }

            return {
              results: results
            };
          },
          cache: true
        },
        templateSelection: formatPart,
        templateResult : formatPart
      };
    };

    $('#parts-popup').on('modal:opening', function(e){
      var button = $(e.relatedTarget);
      if (button.data('value'))
        $(this).find('#part_name').val(button.data('value'));

      el = $('.pe-panel .select2-container--open')
      var select = el.prev();
      $select2target = select.attr('id');
      var select2 = $select2containers[$select2target];
      if (select2)
        select2.select2('close');

      $('.link-input').hide();
      $(this).find('.part_' + select.data('link-type')).show();

      var id = $(this).find('[name="id"]').val();
      basePartsApiUrl = Utils.getApiPath() + '/v2/parts';
      if (id.length) {
        $(this).find('form').attr('action', basePartsApiUrl + '/' + id);
        $(this).find('input[name="_method"]').val('patch');
      } else {
        $(this).find('form').attr('action', basePartsApiUrl);
        $(this).find('input[name="_method"]').val('');
      }
    });

    $('.project-editor').on('click', '.parts-widget .edit-in-modal', function(e){
      var select = $(this).closest('.fields').find('.select2');
      $select2target = select.attr('id');
    });

    function setupSelect2() {
      $('.project-editor .parts-widget .select2').each(function(i, el){
        el = $(el);
        $select2containers[el.attr('id')] = el.select2(select2Options(el.data('type')));
      });
    }
    setupSelect2();

    $('.project-editor').on('ajax:complete', '.remote:not(#parts-popup)', function(xhr, data, status){
       setupSelect2();
    });

    $('#parts-popup').on('modal:open', function(e){
      $(this).find('.part_name').focus();
    });

    $('#parts-popup form').on('ajax:success', function(event, xhr, data, status){
      var select = $('#' + $select2target);
      var tpl = prepareOptionTagForPart(data.part);
      select.html(tpl);
      $select2containers[$select2target].val(data.part.id).trigger('change');
      var parent = select.closest('.fields');

      // update data-field-type inputs after create/update
      var inputs = $(this).find('input, textarea, select');
      inputs.each(function(i, el){
        var field = $(el).data('field-type');
        if (typeof(field) != 'undefined') {
          var input = parent.find('[data-field-type="' + field + '"]');
          if (input.length)
            input.val($(el).val());
        }
      });

      closeModal('#parts-popup');
      $select2target = null;
    });

    function prepareOptionTagForPart(part) {
      var data = _.map(part, function(val, key){
        return val ? 'data-' + key + '="' + _.escape(val) + '"' : null;
      });
      data = _.filter(data, function(val){
        return val;
      });
      if (part.platform) {
        data = data.concat(_.map(part.platform, function(val, key){
          return 'data-platform-' + key + '="' + _.escape(val) + '"';
        }));
      }
      return '<option value="' + part.id + '" ' + data.join(' ') + '>' + part.name + '</option>';
    }

    $('.project-editor').on('click', '.parts-widget .reveal', function(e){
      e.preventDefault();
      var parent = $(this).closest('tbody');
      var target = parent.find('[data-name="' + $(this).data('target') + '"]');
      var panel = $(this).closest('.pe-panel');
      target.slideDown();
      var li = $(this).closest('li');
      var ul = li.closest('ul');
      var tr = ul.closest('tr');
      li.remove();
      if (ul.children().length == 0) {
        tr.remove();
      }
    });

    function resetPartPositions(){
      $('.parts-widget').each(function(j, el){
        $(el).find('tr:not(.removed) input.position').each(function(i){
          $(this)
            .val(i+1)
            .trigger('change');
        });
      });
    }

    $('.project-editor').on('click', '.move-up', '.parts-widget', function(e){
      e.preventDefault();
      var parent = $(this).closest('.fields');
      var prev = parent.prev();
      if (prev.length) {
        parent.insertBefore(prev);
        resetPartPositions();
      }
    });

    $('.project-editor').on('click', '.move-down', '.parts-widget', function(e){
      e.preventDefault();
      var parent = $(this).closest('.fields');
      var next = parent.next()
      if (next.length) {
        parent.insertAfter(next);
        resetPartPositions();
      }
    });

    $('.project-editor').on('nested:fieldAdded', '.parts-widget', function(e){
      var select = $(e.target).find('.select2');
      select.html('<option></option>');
      $select2containers[select.attr('id')] = select.select2(select2Options(select.data('type')));
      resetPartPositions();

      // the blueprint has white spaces and they're copied over when adding a field
      $(e.target).find('textarea, .reset').val('');
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
        if(!fileName) { return; }
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
      pasteZone: null,

      add: function(e, data) {
        file = data.files[0];
        tpl = $('<p class="progress-legend">Uploading...</p><div class="progress progress-striped active"><div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width:0%;">');
        $(".file-upload-progress-container").html(tpl);
        data.context = tpl;

        var form = $(this);
        var _data = data;
        data.context.data('data', data);

        Utils.getApiToken(function(token) {
          $.ajax({
            url: Utils.getApiPath() + '/private/files/signed_url',
            type: 'GET',
            dataType: 'json',
            data: { file: {name: file.name}, context: 'no-context' },
            headers: {
              'Authorization': 'Bearer ' + token
            },
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

        Utils.getApiToken(function(token) {
          $.ajax({
            url: Utils.getApiPath() + '/private/files',
            type: 'POST',
            dataType: 'json',
            headers: {
              'Authorization': 'Bearer ' + token
            },
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
        });
      }
    });

    $('.admin-bar .toggle-checklist').on('click', function(e){
      e.preventDefault();
      $('.admin-bar .admin-checklist').toggle();
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

    cleanUpSelectBlueprint();

    // handles copying code snippets with clipboard plugin
    new Clipboard('.code-widgets .copy-code', {
      target: function(trigger) {
        var widget = $(trigger).closest('.preview-pane');
        var code = widget.find('pre')[0];
        return code;
      }
    })
      .on('success', function(e) {
        var trigger = $(e.trigger);
        var parent = trigger.parent();
        trigger.tooltip('hide');
        parent.tooltip({
          title: 'Copied!',
          trigger: 'manual',
          placement: 'top',
          container: 'body',
        }).tooltip('show');
        window.setTimeout(function(){
          parent.tooltip('destroy');
        }, 1500);
        trigger.blur();

        e.clearSelection();
      })
      .on('error', function(e) {
        var trigger = $(e.trigger);
        var parent = trigger.parent();
        trigger.tooltip('hide');
        parent.tooltip({
          title: 'Press CTRL+C to copy',
          trigger: 'manual',
          placement: 'top',
          container: 'body',
        }).tooltip('show');
        window.setTimeout(function(){
          parent.tooltip('destroy');
        }, 1500);
        trigger.blur();
      });


    $('.code-widgets .sidebar a').on('click', function(e){
      var container = $(this).closest('.code-widgets');
      container.find('.sidebar a, .preview-pane').removeClass('active');

      $(this).addClass('active');
      var target = $($(this).data('target'));
      target.addClass('active');

      setPreviewPaneHeight(target);
    });

    var codeWidget = $('.code-widgets');
    if (codeWidget.length) {
      if (codeWidget.hasClass('single-file') && codeWidget.hasClass('no-preview')) {
        var header = codeWidget.find('.preview-header');
        codeWidget.css('height', header.outerHeight() + 'px');
        updatedScrollEventHandlers();
      } else if (codeWidget.find('.preview-pane').length) {
        setPreviewPaneHeight(codeWidget.first());
      }
    }
  });

  $('#about-project .read-more a').on('click', function(e){
    e.preventDefault();
    $('#about-project').removeClass('collapsed');
  });

})(jQuery, window, document);

function setPreviewPaneHeight(target){
  var header = target.find('.preview-header');
  var body = target.find('.preview-body');
  var height = target.outerHeight() - header.outerHeight();
  body.css('height', height + 'px');
}

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

function cleanUpSelectBlueprint() {
  var targets = $('#part_joins_fields_blueprint, #software_part_joins_fields_blueprint, #hardware_part_joins_fields_blueprint, #tool_part_joins_fields_blueprint');
  targets = _.filter(targets, function(el){ return !$(el).hasClass('ready'); });
  $.each(targets, function(i, el){
    el = $(el);
    var bp = $(el.data('blueprint'));
    var select = bp.find('.select2');
    select.html('<option></option>');
    var name = select.attr('name');
    var type = 'new_' + name.match(/\[([a-z_]+_attributes)\]/)[1].replace('_attributes', '');
    name = name.replace(name.match(/\[[0-9]+\]/)[0], '[' + type + ']');
    select.attr('name', name);
    var id = select.attr('id');
    id = id.replace(id.match(/[0-9]+/)[0], type);
    select.attr('id', id);
    el.data('blueprint', bp.prop('outerHTML'));
    el.addClass('ready');
  });
}

function formatPart(result) {
  if (!result.id || result.id == '' && result.text)
    return $('<span class="select2--text-only">' + result.text + '</span>');

  if (!result.part) {
    if (!result.element) {
      var noMatchPhrase = result.id == -1 ? "Can't find the right one?" : "No results for '" + _.escape(result.q) + "'";
      var newPhrase = 'Create a new ' + (result.type ? result.type : 'one');

      return $("<span>" + noMatchPhrase + " <a href='javascript:void(0)' class='btn btn-sm btn-success edit-in-modal modal-reset' data-modal='#parts-popup' data-value='" + _.escape(result.q) + "'>" + newPhrase + "</a></span>");
    }

    var el = $(result.element);
    var part = {
      name: el.data('name'),
      store_link: el.data('store_link'),
      product_page_link: el.data('product_page_link'),
      image_url: el.data('image_url'),
      status: el.data('status'),
      url: el.data('url')
    };
    if (el.data('platform-id')) {
      var platform = {
        name: el.data('platform-name'),
        logo_url: el.data('platform-logo_url')
      }
    }
  } else {
    var part = result.part;
    var platform = part.platform;
  }

  var output = '<table class="select2-part"><tbody><tr><td class="part-img">';
  if (part.image_url)
    output += '<img src="' + part.image_url + '" />'
  output += '</td><td class="part-description"><div class="part-name">';
  if (platform)
    output += '<img src="' + platform.logo_url + '" class="platform-img"> <span class="platform-name">' + platform.name + '</span> - ';
  var link = part.store_link && typeof(part.store_link) !== 'undefined' ? part.store_link : null;
  if (!link)
    link = part.product_page_link && typeof(part.product_page_link) !== 'undefined' ? part.product_page_link : 'No link';
  output +=  part.name + '</div><div class="part-link"><i class="fa fa-link"></i><span>' + link + '</span></div></td><td class="part-action">'
  if (part.status  == 'pending_review' && !part.url) {
    output += '<a class="btn btn-link btn-sm edit-in-modal" data-modal="#parts-popup">Edit</a>';
  } else {
    output += '<i class="fa fa-lock help" title="This part cannot be edited."></i>';
  }
  output += '</td></tr></tbody></table>';
  return $(output);
};

function loadSlickSlider(opts){
  opts = opts || {};
  target = opts['target'] || $('.image-gallery:visible:not(.slick-initialized):not(.lazyload)');
  delete opts['target'];
  slickOpts = {
    accessibility: false,
    speed: 500,
    fade: true,
    dots: true,
    adaptiveHeight: true,
    nextArrow: '<button type="button" class="slick-next-arr fa fa-chevron-right">Next</button>',
    prevArrow: '<button type="button" class="slick-prev-arr fa fa-chevron-left">Previous</button>'
  };
  for (var attrname in opts) { slickOpts[attrname] = opts[attrname]; }
  target.slick(slickOpts);
  updatedScrollEventHandlers();
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