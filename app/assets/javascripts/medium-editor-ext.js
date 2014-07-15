// - upload files
// - upload images: handle failure + make gallery work (select whether you want to upload a single file or make a gallery; at the end initialize slick)
//        when multiple files are uploaded at once create a gallery
//        add a button hover images to give the option to add more images to the gallery (or transform into one)
// - prevent delete with backspace (is this still happening?)
// - some way to insert code
// - auto link urls in paragraphs


var embedOverlay = '<div class="embed-overlay"><div class="center-align-wrapper"><div class="center-align-inner"><button class="btn btn-danger btn-lg" data-action="delete"><i class="fa fa-trash-o"></button></div></div></div>';

$(function () {

  $(embedOverlay).appendTo('.medium-editor .embed');

  markEmptyParagraphs($('.editable'));

  $('.editable').on('click', '.embed-overlay button', function(e){
    switch ($(this).data('action')) {
      case 'delete':
        frame = $(this).closest('.embed-frame');
        id = frame.attr('data-file-id');
        if (id) deleteFile(id);
        frame.slideUp(function(){
          editorDiv = $(this).closest('.editable');
          $(this).remove();
          editorDiv.trigger('input');
        });
        break;
    }
  });

  $('.editable').on('input', function(e){
    checkAndSaveProject();
  });

  var lastSaved;
  var saveTimerOn;
  function checkAndSaveProject() {
    savedDiv = $('.medium-saved');
    savedDiv.text('Changes not saved...');
    if (saveTimerOn) return;

    now = $.now();
    timeAgo = now - lastSaved;
    if (timeAgo < 5000) {
      window.setTimeout(function(){
        saveTimerOn = false;
        checkAndSaveProject();
      }, timeAgo);
      saveTimerOn = true;
      return;
    }

    saveProject();
  }

  function saveProject() {
    id = $('.project').data('project-id');
    text = editor.serialize()['element-0'].value;
    savedDiv = $('.medium-saved');
    savedDiv.text('Saving...');

    $.ajax('/api/projects/' + id, {
      data: { utf8: '✓', project: { description: text } },
      type: 'PATCH',
      xhr: function() {
          return window.XMLHttpRequest == null || new window.XMLHttpRequest().addEventListener == null
              ? new window.ActiveXObject("Microsoft.XMLHTTP")
              : $.ajaxSettings.xhr();
      },
      success: function(data){
        lastSaved = $.now();
        savedDiv.text('Last saved at ' + getTimeInText() + '.');
      },
      error: function(data){
        savedDiv.text('Error saving! Last saved at ' + getTimeInText(lastSaved) + '.');
      }
    });
    lastSaved = new Date().getTime();
  }

  $('.editable').on('keyup', function(e){
    $('span.default-text', $(this)).replaceWith('<br>');
    $('span').contents().unwrap();

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

  $('.editable').on('blur focusout', '.default-text', function(e){
    $(this).remove();
  });

  $('.editable').on('click dblClick', function(e){
    var selection = retrieveSelection();
    var parent = $(selection.anchorNode).parent();
    if (parent.is('span.default-text')) {
      e.preventDefault();
      focusAtBeginningOfRange(selection.anchorNode);
    }
  });

  $('.editable').on('keypress keydown', function(e){
    var selection = retrieveSelection();
    var node = $(selection.anchorNode);
    var parent = node.parent();
    if (parent.is('span.default-text')) {
      if (e.which !== 0 && e.charCode !== 0 && !e.ctrlKey && !e.metaKey && !e.altKey) {
        parent.remove();
      } else if (e.keyCode == 39) {
        e.preventDefault();
        focusAtBeginningOfRange(parent.parent().next()[0]);
      }
    } else if (node.is('figcaption')) {
      // prevent deleting element
      if (e.keyCode == 8 && node.text() === '') {
        e.preventDefault();
      }
    }
  });

  $('.editable').on('click keyup', function(e){
    checkForSelection();
  });

  $('.text-widget').on('click', 'a.add-media-btn', function(e){
    $(this).next('.media-menu-btns').toggleClass('is-open');
  });

  $('.text-widget').on('click', 'a.media-btn-action', function(e){
    e.preventDefault();
    btn = $(this);

    switch(btn.data('action')) {
      case 'insert':
        span = '<span class="default-text">' + btn.data('default-text') + '</span>';
        $(curNode).html(span);
        focusAtBeginningOfRange($(curNode).children().first()[0]);
        break;
      case 'upload':
        $(curNode).replaceWith('<div id="upload-placeholder"></div>');
        $('.medium-file-upload').find('input[type=file]').click();
        break;
    }

    m = btn.closest('.media-menu')
    m.hide()
    m.find('.media-menu-btns').removeClass('is-open');
  });

  function detectFileType(file) {
    if (file.type == 'image/png' || file.type == 'image/jpeg' || file.type == 'image/gif') {
      return 'image'
    } else {
      return 'document';
    }
  }

  var fileuploadFunctions = {
    image: {
      addToTpl: function(data){
        var reader = new FileReader();
        reader.onload = function(e) {
          img = '<img src="' + e.target.result + '">'
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

  var iFile = 0;
  $('.medium-file-upload').fileupload({
    dataType: 'xml', // This is really important as s3 gives us back the url of the file in a XML document
    limitMultiFileUploads: 1,
    sequentialUploads: true,
    limitConcurrentUploads: 1,
    dropZone: '.file-drop.medium-file-upload',

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

      tpl = $('<div class="embed-frame" id="tmp-img-' + iFile + '" contenteditable="false"><figure class="embed original" contenteditable="false"><div class="embed-overlay is-visible"><div class="center-align-wrapper"><div class="center-align-inner"><p class="progress-legend">Uploading...</p><div class="progress progress-striped active"><div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width:0%;"></div></div></div></div></figure></div>');
      tpl.insertBefore('#upload-placeholder');
      data.context = 'tmp-img-' + iFile;
      iFile++;

      if (errors.length > 0) {
        target = $('#' + data.context + ' .progress');
        target.replaceWith('<div class="help-block has-error">Error: ' + errors.join(', ')+'</span>');
      } else {
        fileuploadFunctions[fileType].addToTpl(data);

        $('#' + data.context).data('data', data);
        $('#' + data.context).data('fileType', fileType);

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
            console.log('fail');

            // <%= file_type %>Functions.fail($('#' + context).data('data'));
          }
        });
      }
    },

    fail: function(e, data){
      form = $('.medium-file-upload');
      // <%= file_type %>Functions.fail(form.data('data'));
      console.log('fail');
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
        $('#upload-placeholder').remove();
      }
    },

    success: function(data) {
      var url = $(data).find('Location').text(); // or Key for path
      form = $('.medium-file-upload');
      form.data('url', url);  // pass it to 'done'
    },

    done: function(e, data){
      $('#' + data.context).data('data', data);

      $(this).data('data', data);
      url = $(this).data('url');
      fileType = $('#' + data.context).data('fileType');

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
          $('.embed-overlay', el).replaceWith(embedOverlay);
          $('figure', el).append("<figcaption contenteditable='true' placeholder='Type in to add a caption'></figcaption>");
          el.closest('.editable').trigger('input');
        },
          error: function(data) {
            context = decodeURIComponent($.urlParam(this.url, 'context'));
            // <%= file_type %>Functions.fail($('#' + context).data('data'));
          }
      });
    }
  });
});

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
  // console.log('sel change');
  if (node.is('p.paragraph--empty')) {
    // console.log('entered empty');
    showMediaButtons(node);
  } else {
    hideMediaButtons(node);
  }
}

function showMediaButtons(node) {
  var top = node.offset().top;
  w = node.closest('.text-widget');
  b = w.find('.media-menu');
  b.css('top', top - w.offset().top);
  b.show();
}

function hideMediaButtons(node) {
  w = node.closest('.text-widget');
  b = w.find('.media-menu');
  b.hide();
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
}

function insertEmbedTag(url, node) {
  $.ajax('/api/embeds', {
    asynx: false,
    data: { url: url },
    success: function(data){
      if (data.code) {
        div = '<div contenteditable="false" class="embed-frame" data-embed="' + data.url + '">' + data.code + '</div>';
        node.replaceWith(div);
        $(embedOverlay).appendTo('.embed', $('.embed-frame[data-embed="' + data.url + '"]'));
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
  parent.children('p').each(function() {
    el = $(this);
    if (el.text() === '') {
      el.addClass('paragraph--empty');
    } else {
      el.removeClass('paragraph--empty');
    }
  });
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
    /**
    * Extend MediumEditor's serialize function to get rid of unnecesarry Medium Editor Insert Plugin stuff
    *
    * @return {object} content Object containing HTML content of each element
    */

    MediumEditor.prototype.serialize = function () {
      var i, j,
          elementid,
          content = {},
          $clone, $inserts, html;
      for (i = 0; i < this.elements.length; i += 1) {
        elementid = (this.elements[i].id !== '') ? this.elements[i].id : 'element-' + i;

        $clone = $(this.elements[i]).clone();
        $inserts = $('.embed-frame', $clone);
        $('figcaption', $inserts).each(function(){
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
  }
}(jQuery));