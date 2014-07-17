// - some way to insert code
// - handle components list
// - auto link urls in paragraphs
// - generate description from widgets


var embedOverlay = {
  main: '<div class="embed-overlay"><div class="center-align-wrapper"><div class="center-align-inner embed-overlay-content"><button class="btn btn-danger btn-lg" data-action="delete"><i class="fa fa-trash-o"></button></div></div></div>',
  addSlideBtn: '<button class="btn btn-success btn-lg" data-action="add-slide"><i class="fa fa-plus"></button>',
  moveUpBtn: '<button class="btn btn-default btn-lg" data-action="move-up"><i class="fa fa-arrow-up"></button>',
  moveDownBtn: '<button class="btn btn-default btn-lg" data-action="move-down"><i class="fa fa-arrow-down"></button>'
}

var editor;
$(function() {
  editor = {
    self: null,
    elements: $('.editable'),
    status: $('.medium-status'),
    error: $('.medium-error'),
    lastSaved: null,
    saveTimerOn: false,
    unsavedChanges: false,
    iFile: 0,

    activate: function(){
      var _ = this;

      _.self = new MediumEditor(_.elements, {
        buttonLabels: 'fontawesome',
        cleanPastedHTML: true,
        targetBlank: true,
        placeholder: '',
        buttons: ['bold', 'italic', 'underline', 'anchor', 'header1', 'header2', 'unorderedlist', 'orderedlist']
      });

      _.elements.addClass('editable-activated');

      formTpl = "<form action='https://#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com' method='post' enctype='multipart/form-data' class='medium-file-upload' style='display:none;'>";
      formTpl += "<input name='key' type='hidden'>";
      formTpl += "<input name='AWSAccessKeyId' type='hidden' value='#{ENV['AWS_ACCESS_KEY_ID']}'>";
      formTpl += "<input name='acl' type='hidden' value='public-read'>";
      formTpl += "<input name='policy' type='hidden'>";
      formTpl += "<input name='signature' type='hidden'>";
      formTpl += "<input name='success_action_status' type='hidden' value='201'>";
      formTpl += "<input type='file' name='file' multiple>";
      formTpl += "</div>";
      formTpl += "</form>";

      $($(formTpl)).appendTo($('.medium-editor'));

      $(embedOverlay.main).appendTo(_.elements.find('.embed'));
      $(embedOverlay.addSlideBtn).appendTo(_.elements.find('.image-gallery.slick-slider .embed-overlay-content'));

      markEmptyParagraphs(_.elements);
      loadPlaceholders(_.elements.find('.embed-frame'));

      console.log('editor activated');
      return _.self;
    },

    disable: function() {
      var _ = this;

      if (_.self) {
        if (_.unsavedChanges) _.saveProject();

        _.self.deactivate();
        _.elements.removeClass('editable-activated');

        _.elements.find('.embed-overlay').remove();
        $('.paragraph--empty').removeClass('paragraph--empty');
        $('.default-text').remove();

        console.log('editor disabled');
      }
      return _.self;
    },

    checkAndSaveProject: function() {
      var _ = this;

      if (!this.self.isActive) return;

      _.status.text('Changes not saved...');
      if (_.saveTimerOn) return;

      now = $.now();
      timeAgo = now - _.lastSaved;
      if (timeAgo < 5000) {
        window.setTimeout(function(){
          _.saveTimerOn = false;
          _.checkAndSaveProject();
        }, timeAgo);
        _.saveTimerOn = true;
        return;
      }

      _.saveProject();
    },

    saveProject: function() {
      var _ = this;

      id = $('.project').data('project-id');
      text = _.self.serialize()['element-0'].value;
      _.status.text('Saving...');

      $.ajax('/api/projects/' + id, {
        data: { utf8: '✓', project: { description: text } },
        type: 'PATCH',
        xhr: function() {
            return window.XMLHttpRequest == null || new window.XMLHttpRequest().addEventListener == null
                ? new window.ActiveXObject("Microsoft.XMLHTTP")
                : $.ajaxSettings.xhr();
        },
        success: function(data){
          _.status.text('All changes saved');
          _.unsavedChanges = false;
        },
        error: function(data){
          _.status.text('Error saving! Last saved at ' + getTimeInText(_.lastSaved) + '.');
        }
      });
      _.lastSaved = new Date().getTime();
    }
  }
});

$(function () {
  $('.medium-start-edit').click(function(e){
    editor.activate();
    $('.medium-start-edit').hide();
    $('.medium-stop-edit').show();
    e.preventDefault();
  });

  $('.medium-stop-edit').click(function(e){
    editor.disable();
    $('.medium-stop-edit').hide();
    $('.medium-start-edit').show();
    e.preventDefault();
  });

  $('.medium-editor').on('click', '.editable.editable-activated .embed-overlay button', function(e){
    hideMediaButtons($(this));
    switch ($(this).data('action')) {
      case 'delete':
        frame = $(this).closest('.embed-frame');
        id = frame.attr('data-file-id');
        if (id) deleteFile(id);
        $editorDiv = frame.closest('.editable.editable-activated');
        if (frame.hasClass('slick-slide')) {
          frame.fadeOut(function(){
            slider = $(this).closest('.slick-slider');
            if (slider.find('.slick-slide').length > 1) {
              slider.slickRemove(slider.slickCurrentSlide());
              $(this).remove();
            } else {
              slider.remove();
            }
            $editorDiv.trigger('input');
          });
        } else {
          frame.slideUp(function(){
            $(this).remove();
            $editorDiv.trigger('input');
          });
        }
        break;
      case 'add-slide':
        $('#upload-placeholder').remove();
        $('.last-uploaded-file').removeClass('last-uploaded-file');
        frame = $(this).closest('.slick-track');
        $('<div id="upload-placeholder"></div>').appendTo(frame);
        $('.medium-file-upload').find('input[type=file]').click();
    }
  });

  $('.medium-editor').on('input', '.editable.editable-activated', function(e){
    editor.unsavedChanges = true;
    editor.checkAndSaveProject();
  });

  $('.medium-editor').on('keyup', '.editable.editable-activated', function(e){
    $(this).find('span.default-text-focused').replaceWith('<br>');
    $(this).find('p span').contents().unwrap();

    markEmptyParagraphs($(this));
    if (e.keyCode == 13) {
      sel = retrieveSelection();
      node = $(sel.anchorNode);
      url = node.prev().text();
      if (/^http/.test(url)) {
        insertEmbedTag(url, node.prev());
      }
    }
  });

  $('.medium-editor').on('blur focusout', '.editable.editable-activated .default-text-focused', function(e){
    $(this).remove();
  });

  $('body').on('click', function(e){
    hideMediaButtons($('.medium-editor'));
    resetPos();
  }).find('.medium-editor').on('click', function(e) {
    e.stopPropagation();
  });

  $('.medium-editor').on('click dblClick', '.editable.editable-activated', function(e){
    var selection = retrieveSelection();
    var parent = $(selection.anchorNode).parent();
    if (parent.is('span.default-text')) {
      e.preventDefault();
      focusAtBeginningOfRange(selection.anchorNode);
    }
  });

  $('.medium-editor').on('keypress keydown', '.editable.editable-activated', function(e){
    var selection = retrieveSelection();
    var node = $(selection.anchorNode);
    var parent = node.parent();

    if (parent.is('span.default-text')) {
      if (e.which !== 0 && e.charCode !== 0 && !e.ctrlKey && !e.metaKey && !e.altKey) {
        if (parent.is('.default-text-focused')) {
          parent.remove();
        } else {
          node.remove();
        }
      } else if (e.keyCode == 39) {
        e.preventDefault();
        focusAtBeginningOfRange(parent.parent().next()[0]);
      // prevent deleting element
      } else if (e.keyCode == 8) {
          e.preventDefault();
      }
    } else if (parent.is('figcaption')) {
      if (e.keyCode == 8 && parent.text().length == 1) {
        e.preventDefault();
        loadPlaceholder(parent.parent().parent(), true);
        focusAtBeginningOfRange(parent.find('.default-text')[0]);
        parent.closest('.editable').trigger('input');
      }
    }
  });

  $('.medium-editor').on('keyup', '.editable.editable-activated', function(e){
    var selection = retrieveSelection();
    var node = $(selection.anchorNode);
    var parent = node.parent();
    if (node.is('figcaption')) {
      if (e.keyCode == 8 && node.text() == '') {
        loadPlaceholder(node.parent().parent(), true);
        focusAtBeginningOfRange(node.find('.default-text')[0]);
      }
    }
  });

  $('.medium-editor').on('click keyup', '.editable.editable-activated', function(e){
    checkForSelection();
  });

  $('.medium-editor').on('click', 'a.add-media-btn', function(e){
    $(this).next('.media-menu-btns').toggleClass('is-open');
  });

  $('.medium-editor').on('click', 'a.media-btn-action', function(e){
    e.preventDefault();
    btn = $(this);

    switch(btn.data('action')) {
      case 'insert':
        span = '<span class="default-text-focused default-text">' + btn.data('default-text') + '</span>';
        $(curNode).html(span);
        focusAtBeginningOfRange($(curNode).children().first()[0]);
        break;
      case 'upload':
        $('#upload-placeholder').remove();
        $(curNode).replaceWith('<div id="upload-placeholder"></div>');
        $('.medium-file-upload').find('input[type=file]').click();
        break;
    }

    m = btn.closest('.media-menu')
    m.hide()
    m.find('.media-menu-btns').removeClass('is-open');
  });

  var fileuploadFunctions = {
    image: {
      addToTpl: function(data){
        var reader = new FileReader();
        reader.onload = function(e) {
          img = '<img src="' + e.target.result + '">';

          el = $('#' + data.context);
          slider = el.closest('.slick-slider');
          if (slider.length > 0) {
            slider = $(slider[0]);
            slider.slickAdd(el);
            slider.slickGoTo($('.slick-slide', slider).length - 1);
          }

          $(img).appendTo('#' + data.context + ' .embed');
        }
        reader.readAsDataURL(data.files[0]);
      }
    },
    document: {
      addToTpl: function(data){
        fileTpl = '<div class="document-widget"><div class="file"><i class="fa fa-file-o fa-lg"></i><a>' + data.files[0].name + '</a></div></div>';
        $(fileTpl).appendTo('#' + data.context + ' .embed');
      }
    }
  }

  $('.medium-file-upload').fileupload({
    dataType: 'xml', // This is really important as s3 gives us back the url of the file in a XML document
    limitMultifileUploads: 1,
    sequentialUploads: true,
    limitConcurrentUploads: 1,
    // dropZone: '.file-drop.medium-file-upload',

    add: function(e, data) {
      file = data.files[0];

      validations = {
        maxFileSize: $('.medium-file-upload input[name="file"]').data('max-file-size')
      }
      dataFileTypes = $('.medium-file-upload input[name="file"]').data('file-type');
      if (dataFileTypes != 'undefined') {
        validations['fileType'] = dataFileTypes;
      }
      errors = checkFileForErrors(file, validations);
      fileType = detectFileType(file);

      tpl = $('<div class="embed-frame" id="tmp-img-' + editor.iFile + '" contenteditable="false"><figure class="embed original" contenteditable="false"><div class="embed-overlay is-visible"><div class="center-align-wrapper"><div class="center-align-inner"><p class="progress-legend">Uploading...</p><div class="progress progress-striped active"><div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width:0%;"></div></div></div></div></figure></div>');
      tpl.addClass('file-upload-in-progress');
      if ($('#upload-placeholder').length > 0) {
        $('#upload-placeholder').replaceWith(tpl);
        tpl.addClass('last-uploaded-file')
      } else if ($('.last-uploaded-file').length > 0) {
        tpl.insertAfter('.last-uploaded-file');
        $('.last-uploaded-file').removeClass('last-uploaded-file');
        tpl.addClass('last-uploaded-file');

        slider = tpl.closest('.slick-slider');
        if (slider.length == 0 && fileType == 'image') {
          $('.file-upload-in-progress').wrapAll('<div class="image-gallery" />');
          loadSlickSlider();
        }
      } else {
        console.log("couldn't find where to insert file");
      }
      data.context = 'tmp-img-' + editor.iFile;
      editor.iFile++;

      if (errors.length > 0) {
        $('#' + data.context).replaceWith("<div class='help-block has-error upload-error'>Couldn't upload " + file.name + ': ' + errors.join(', ')+'</span>');
      } else {
        fileuploadFunctions[fileType].addToTpl(data);

        $('#' + data.context).data('data', data);

        $.ajax({
          url: '/files/signed_url',
          type: 'GET',
          dataType: 'json',
          data: {file: {name: file.name}, context: data.context},
          async: false,
          success: function(data) {
            form = $('.medium-file-upload');
            form.find('input[name=key]').val(data.key);
            form.find('input[name=policy]').val(data.policy);
            form.find('input[name=signature]').val(data.signature);

            $('#' + data.context).data('data').submit();
          },
          error: function(data) {
            context = decodeURIComponent($.urlParam(this.url, 'context'));
            handleUploadErrors($('#' + context));
          }
        });
      }
    },

    fail: function(e, data){
      form = $('.medium-file-upload');
      handleUploadErrors(form);
    },

    progress: function(e, data) {
      progress = parseInt(data.loaded / data.total * 100, 10);
      target = $('#' + data.context + ' .progress-bar');
      target.css('width', progress + '%');
      if (progress == 100) {
        target.addClass('progress-bar-success');
      }
    },

    progressall: function(e, data) {
      progress = parseInt(data.loaded / data.total * 100, 10);
      // console.log(progress);
      if (progress == 100) {
        $('.last-uploaded-file').removeClass('last-uploaded-file');
        $('.file-upload-in-progress').removeClass('file-upload-in-progress');
        $('#upload-placeholder').remove();
      }
    },

    success: function(data) {
      var url = $(data).find('Location').text(); // or Key for path
      form = $('.medium-file-upload');
      form.attr('data-url', url);  // pass it to 'done'
    },

    done: function(e, data){
      $('#' + data.context).data('data', data);

      $(this).data('data', data);
      url = $(this).attr('data-url');
      fileType = detectFileType(data.files[0]);

      $.ajax({
        url: '/files',
        type: 'POST',
        dataType: 'json',
        data: {
          file_url: url,
          file_type: fileType,
          context: data.context,
          attachable_id: $('.project').data('project-id'),
          attachable_type: 'Project'
        },
        async: false,
        success: function(data) {
          id = data.id;
          el = $('#' + data.context);
          el.attr('id', '');
          el.attr('data-file-id', id);
          $('.embed-overlay', el).replaceWith(embedOverlay.main);
          $('figure', el).append("<figcaption contenteditable='true' data-default-text='Type in a caption' data-disable-toolbar='true'></figcaption>");
          slider = el.closest('.slick-slider');
          if (slider.length > 0) {
            $(embedOverlay.addSlideBtn).appendTo(el.find('.embed-overlay-content'));
          }
          loadPlaceholder(el, true);
          insertBlankParagraphAfter(el);
          el.closest('.editable.editable-activated').trigger('input');
        },
          error: function(data) {
            context = decodeURIComponent($.urlParam(this.data, 'context'));
            handleUploadErrors($('#' + context));
          }
      });
    }
  });

  // handles status bar
  if ($('.medium-status-bar.static').length > 0) {
    var stickyTop = $('.medium-status-bar.static').offset().top;
    $(window).scroll(function(){ // scroll event
      var windowTop = $(window).scrollTop();
      affixed = $('.medium-status-bar.affixed');

      if (stickyTop < windowTop) {
        if (affixed.is(':hidden')) {
          affixed.slideDown(200);
        }
      }
      else {
        if (affixed.is(':visible')) {
          affixed.hide();
        }
      }
    });
  }

  // prevent leaving page with unsaved changes
  window.addEventListener("beforeunload", function (e) {
    if (editor.unsavedChanges) {
      var message = "There are unsaved changes.";

      (e || window.event).returnValue = message;
      return message;
    }
  });
});

function detectFileType(file) {
  if (file.type == 'image/png' || file.type == 'image/jpeg' || file.type == 'image/gif') {
    return 'image'
  } else {
    return 'document';
  }
}

function handleUploadErrors(dataContainer) {
  data = dataContainer.data('data');
  target = $('#' + data.context);
  file = data.files[0];
  editor.error.text('An error occurred while uploading ' + file.name + '. Please try again.');
  $('.medium-error-bubble').fadeIn(function(){
    $t = $(this);
    window.setTimeout(function(){
      $t.fadeOut();
    }, 2500)
  });
  target.replaceWith('<p class="paragraph--empty"><br></p>');
}

function checkFileForErrors(file, validations) {
  errors = [];
  maxFileSize = validations['maxFileSize'];
  if (file.size > maxFileSize) {
    errors.push('Maximum file size is ' + maxFileSize / 1000000 + 'MB');
  }
  if (validations['fileType'] != undefined) {
    fileType = validations['fileType'];
    regexp = new RegExp('(\.|\/)(' + fileType.split(',').join('|') + ')$', 'gi');
    type = (file.type != '') ? file.type : file.name
    if (!regexp.test(type)) {
      msg = fileType.split(',').join(', ');
      errors.push('Allowed file types are ' + msg);
    }
  }
  return errors;
}

$.urlParam = function(url, name){
  results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(url);
  return results[1] || 0;
}

function retrieveSelection() {
  var selection;
  if (window.getSelection)
    selection = window.getSelection();
  else if (document.selection && document.selection.type != "Control")
    selection = document.selection;
  return selection;
}

var curPos;
var curNode;
function checkForSelection() {
  var selection = retrieveSelection();
  var oldPos = curPos;
  var oldNode = curNode;
  curPos = selection.extentOffset;
  curNode = selection.focusNode;
  if (oldPos == curPos && oldNode == curNode) return;

  var node = $(selection.anchorNode);
  if (node.is('p.paragraph--empty')) {
    showMediaButtons(node);
  } else {
    hideMediaButtons(node);
  }
}

function resetPos() {
  curNode = null;
  curPos = null;
}

function showMediaButtons(node) {
  var top = node.offset().top;
  w = node.closest('.medium-editor');
  b = w.find('.media-menu');
  b.css('top', top - w.offset().top);
  b.show();
}

function hideMediaButtons(node) {
  w = node.closest('.medium-editor');
  b = w.find('.media-menu');
  b.hide();
  b.find('.media-menu-btns').removeClass('is-open');
}

function focusAtBeginningOfRange(div) {
  var sel, range;
  if (window.getSelection && document.createRange) {
    range = document.createRange();
    range.selectNodeContents(div);
    range.collapse(true);
    sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(range);
  } else if (document.body.createTextRange) {
    range = document.body.createTextRange();
    range.moveToElementText(div);
    range.collapse(true);
    range.select();
  }
  $(div).trigger('click');
}

function insertEmbedTag(url, node) {
  $.ajax('/api/embeds', {
    asynx: false,
    data: { url: url },
    success: function(data){
      if (data.code) {
        div = $('<div contenteditable="false" class="embed-frame" data-embed="' + data.url + '">' + data.code + '</div>');
        $(embedOverlay.main).appendTo(div.find('.embed'));
        node.replaceWith(div);
        loadPlaceholder(div, true);
        insertBlankParagraphAfter(div);
      } else {
        link = '<a href="' + data.url + '">' + data.url + '</a>';
        node.html(link);
      }
    },
    type: 'GET'
  });
}

function getTimeInText(dt){
  var dt = new Date();
  var time = pad(dt.getHours()) + ":" + pad(dt.getMinutes()) + ":" + pad(dt.getSeconds());
  return time;
}

function pad(n) {
  return ('0' + n).slice(-2)
}

function markEmptyParagraphs(parent) {
  parent.find('p').each(function() {
    el = $(this);
    if (el.text() === '') {
      el.addClass('paragraph--empty');
    } else {
      el.removeClass('paragraph--empty');
    }
  });
}

function insertBlankParagraphAfter(node) {
  next = node.next();
  if (next.length == 0 || next.prop('tagName').toLowerCase() != 'p') {
    next = $('<p class="paragraph--empty"><br></p>')
    next.insertAfter(node);
  }
  focusAtBeginningOfRange(next[0]);
}

function loadPlaceholders(elements) {
  elements.each(function(){
    loadPlaceholder($(this));
  });
}

function loadPlaceholder(el, force) {
  force = force || false;

  captionEl = el.find('figcaption');
  captionText = $.trim(captionEl.text());
  defaultText = captionEl.data('default-text');
  if (captionEl.length > 0 && (captionText == '' || force) && typeof(defaultText) != 'undefined') {
    captionEl.html('<span class="default-text">' + defaultText + '</span>');
  }
}

function deleteFile(id) {
  $.ajax({
    url: '/files/' + id,
    type: 'DELETE'
  })
}

(function ($) {
  /**
  * Extend MediumEditor functions if the editor exists
  */
  if (MediumEditor && typeof(MediumEditor) === "function") {

    // method overloaded to adapt to clean up app-specific markup
    MediumEditor.prototype.serialize = function () {
      var i, j,
          elementid,
          content = {},
          $clone, $inserts, html;
      for (i = 0; i < this.elements.length; i += 1) {
        elementid = (this.elements[i].id !== '') ? this.elements[i].id : 'element-' + i;

        $clone = $(this.elements[i]).clone();

        // clearing slick markup because unslick() doesn't work as closed
        $('.image-gallery .slick-dots', $clone).remove();
        $('.image-gallery .slick-prev', $clone).remove();
        $('.image-gallery .slick-next', $clone).remove();
        $('.image-gallery .slick-slide', $clone)
          .unwrap().unwrap()
          .removeClass('slick-slide slick-active slick-visible')
          .removeAttr('style');
        $('.image-gallery', $clone).removeClass('slick-initialized slick-slider');

        $clone.find('.default-text').remove();
        $inserts = $clone.find('.embed-frame');
        $inserts.find('figcaption').each(function(){
          frame = $(this).closest('.embed-frame');
          frame.attr('data-caption', $(this).text());
        });
        $inserts.children().remove();

        html = $clone.html().trim();
        content[elementid] = {
          value: html
        };
      }
      return content;
    };

    // method overloaded to disable toolbar on specified elements
    MediumEditor.prototype.checkSelectionElement = function (newSelection, selectionElement) {
      var i;
      this.selection = newSelection;
      this.selectionRange = this.selection.getRangeAt(0);
      // disable toolbar on specified elements
      anchor = newSelection.anchorNode;
      if (!anchor.parentNode.getAttribute('data-disable-toolbar')) {
        for (i = 0; i < this.elements.length; i += 1) {
            if (this.elements[i] === selectionElement) {
                this.setToolbarButtonStates()
                    .setToolbarPosition()
                    .showToolbarActions();
                return;
            }
        }
      }
      this.hideToolbarActions();
    };
  }
}(jQuery));