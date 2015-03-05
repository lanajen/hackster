WYMeditor.editor.prototype._dialog = WYMeditor.editor.prototype.dialog;

WYMeditor.editor.prototype.dialog = function (dialogType, dialogFeatures, bodyHtml) {
  var wym = this,
      features = dialogFeatures || wym._options.dialogFeatures,
      //wDialog = window.open('', 'dialog', features),
      sBodyHtml,
      h = WYMeditor.Helper,
      dialogHtml,
      wDialog,
      doc;

  wDialog = 1;
  console.log(dialogType);
  console.log(dialogFeatures);
  console.log(bodyHtml);

  if (wDialog) {
      sBodyHtml = "";

      switch (dialogType) {

      case (WYMeditor.DIALOG_LINK):
          sBodyHtml = wym._options.dialogLinkHtml;
          break;
      case (WYMeditor.DIALOG_IMAGE):
          sBodyHtml = wym._options.dialogImageHtml;
          break;
      case (WYMeditor.DIALOG_TABLE):
          sBodyHtml = wym._options.dialogTableHtml;
          break;
      case (WYMeditor.DIALOG_PASTE):
          sBodyHtml = wym._options.dialogPasteHtml;
          break;
      case (WYMeditor.PREVIEW):
          sBodyHtml = wym._options.dialogPreviewHtml;
          break;
      default:
          sBodyHtml = bodyHtml;
          break;
      }

      // Construct the dialog
      dialogHtml = wym._options.dialogHtml;
      dialogHtml = h.replaceAllInStr(
          dialogHtml,
          WYMeditor.BASE_PATH,
          wym._options.basePath
      );
      dialogHtml = h.replaceAllInStr(
          dialogHtml,
          WYMeditor.DIRECTION,
          wym._options.direction
      );
      dialogHtml = h.replaceAllInStr(
          dialogHtml,
          WYMeditor.WYM_PATH,
          wym._options.wymPath
      );
      dialogHtml = h.replaceAllInStr(
          dialogHtml,
          WYMeditor.JQUERY_PATH,
          wym._options.jQueryPath
      );
      dialogHtml = h.replaceAllInStr(
          dialogHtml,
          WYMeditor.DIALOG_TITLE,
          wym._encloseString(dialogType)
      );
      dialogHtml = h.replaceAllInStr(
          dialogHtml,
          WYMeditor.DIALOG_BODY,
          sBodyHtml
      );
      dialogHtml = h.replaceAllInStr(
          dialogHtml,
          WYMeditor.INDEX,
          wym._index
      );

      dialogHtml = wym.replaceStrings(dialogHtml);

      console.log(dialogHtml);
      console.log(wym);
      console.log(wym._doc);

      $(dialogHtml).insertAfter(wym.element);

      //doc = wDialog.document;
      //doc.write(dialogHtml);
      //doc.close();
  }
};

/**
* The catchpaste plugin call automatically the paste dialog when user
* press Ctrl + V combinaison in editor.
*
*/
WYMeditor.editor.prototype.sbCatchPaste = function(options) {
  var wym = this;
  var doc = this._doc;

  _sbCatchPaste = function(e) {
    e.stopPropagation();
    e.preventDefault();
    // this probably doesn't work on other browsers but chrome
    var text = e.originalEvent.clipboardData.getData('Text');
    if (text.search(/\n/g) != -1) {
      //split the data, using newlines as the separator
      var aP = text.split(/\n/);
      text = '';
      for (x = aP.length - 1; x >= 0; x--) {
        text += "<p>" + aP[x] + "</p>";
      }
    }
    wym.insert(text);
    return true;
  }

  // Unbind des évènements préalablement mis en place (sous IE)
  $(doc.body).unbind('paste').unbind('beforepaste');
  if(jQuery.isFunction(doc.body.onpaste)) {
     doc.body.onpaste = function() {};
  }
  if(jQuery.isFunction(doc.onbeforepaste)) {
     doc.body.onbeforepaste = function() {};
  }

  // Capture de tous les évènements devant appeler le dialogue Paste
  // $(doc.body).on('keydown', 'Ctrl+V', _sbCatchPaste);
  // $(doc.body).on('keydown', 'Meta+V', _sbCatchPaste);
  // $(doc.body).on('keydown', 'Shift+Insert', _sbCatchPaste);

  $(doc.body).on('paste', _sbCatchPaste);
  $(doc.body).on('beforepaste', _sbCatchPaste);
};

WYMeditor._initDialog = function (index) {
    var wym = WYMeditor.INSTANCES[index],
        selected = wym.selectedContainer(),
        dialogType = jQuery(wym._options.dialogTypeSelector).val(),
        sStamp = wym.uniqueStamp(),
        tableOnClick;

    jQuery(window).bind('beforeunload', function () {
        wym.focusOnDocument();
    });

    if (dialogType === WYMeditor.DIALOG_LINK) {
        // ensure that we select the link to populate the fields
        if (selected && selected.tagName &&
                selected.tagName.toLowerCase !== WYMeditor.A) {
            selected = jQuery(selected).parentsOrSelf(WYMeditor.A);
        }

        // fix MSIE selection if link image has been clicked
        if (!selected && wym._selectedImage) {
            selected = jQuery(wym._selectedImage).parentsOrSelf(WYMeditor.A);
        }
    }

    // pre-init functions
    if (jQuery.isFunction(wym._options.preInitDialog)) {
        wym._options.preInitDialog(wym, window);
    }

    // auto populate fields if selected container (e.g. A)
    if (selected) {
        jQuery(wym._options.hrefSelector).val(jQuery(selected).attr(WYMeditor.HREF));
        jQuery(wym._options.srcSelector).val(jQuery(selected).attr(WYMeditor.SRC));
        jQuery(wym._options.titleSelector).val(jQuery(selected).attr(WYMeditor.TITLE));
        jQuery(wym._options.relSelector).val(jQuery(selected).attr(WYMeditor.REL));
        jQuery(wym._options.altSelector).val(jQuery(selected).attr(WYMeditor.ALT));
    }

    // auto populate image fields if selected image
    if (wym._selectedImage) {
        jQuery(
            wym._options.dialogImageSelector + " " + wym._options.srcSelector
        ).val(jQuery(wym._selectedImage).attr(WYMeditor.SRC));
        jQuery(
            wym._options.dialogImageSelector + " " + wym._options.titleSelector
        ).val(jQuery(wym._selectedImage).attr(WYMeditor.TITLE));
        jQuery(
            wym._options.dialogImageSelector + " " + wym._options.altSelector
        ).val(jQuery(wym._selectedImage).attr(WYMeditor.ALT));
    }

    jQuery(wym._options.dialogLinkSelector + " " +
            wym._options.submitSelector).submit(function () {

        var sUrl = jQuery(wym._options.hrefSelector).val(),
            link;
        if (sUrl.length > 0) {

            if (selected[0] && selected[0].tagName.toLowerCase() === WYMeditor.A) {
                link = selected;
            } else {
                wym._exec(WYMeditor.CREATE_LINK, sStamp);
                link = jQuery("a[href=" + sStamp + "]", wym._doc.body);
            }

            link.attr(WYMeditor.HREF, sUrl);
            link.attr(WYMeditor.TITLE, jQuery(wym._options.titleSelector).val());
            link.attr(WYMeditor.REL, jQuery(wym._options.relSelector).val());
        }
        window.close();
    });

    jQuery(wym._options.dialogImageSelector + " " +
            wym._options.submitSelector).submit(function (e) {
        e.preventDefault();

        var sUrl = jQuery(wym._options.srcSelector).val(),
            $img;
        if (sUrl.length > 0) {

            wym._exec(WYMeditor.INSERT_IMAGE, sStamp);

            $img = jQuery("img[src$=" + sStamp + "]", wym._doc.body);
            $img.attr(WYMeditor.SRC, sUrl);
            $img.attr(WYMeditor.TITLE, jQuery(wym._options.titleSelector).val());
            $img.attr(WYMeditor.ALT, jQuery(wym._options.altSelector).val());
        }
        window.close();
    });

    tableOnClick = WYMeditor._makeTableOnclick(wym);
    jQuery(wym._options.dialogTableSelector + " " + wym._options.submitSelector)
        .submit(tableOnClick);

    jQuery(wym._options.dialogPasteSelector + " " +
            wym._options.submitSelector).submit(function () {

        var sText = jQuery(wym._options.textSelector).val();
        wym.paste(sText);
        window.close();
    });

    jQuery(wym._options.dialogPreviewSelector + " " +
        wym._options.previewSelector).html(wym.html());

    //cancel button
    jQuery(wym._options.cancelSelector).mousedown(function () {
        window.close();
    });

    //pre-init functions
    if (jQuery.isFunction(wym._options.postInitDialog)) {
        wym._options.postInitDialog(wym, window);
    }

};