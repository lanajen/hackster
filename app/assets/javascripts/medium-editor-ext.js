// - show last time saved somewhere (saved status)
// - upload images and docs
// - auto insert images
// - prevent delete with backspace + delete button for widgets
// - some way to insert code


$(function () {

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
    $(this).children('p').each(function() {
      el = $(this);
      if (el.text() === '') {
        el.addClass('paragraph--empty');
      } else {
        el.removeClass('paragraph--empty');
      }
    });
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
    btn = $(this);
    // console.log(btn.data('media'));
    span = '<span class="default-text">' + btn.data('default-text') + '</span>';
    $(curNode).html(span);
    focusAtBeginningOfRange($(curNode).children().first()[0]);
    m = btn.closest('.media-menu')
    m.hide()
    m.find('.media-menu-btns').removeClass('is-open');
  });
});

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