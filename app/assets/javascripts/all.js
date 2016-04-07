function setAffixableBottom() {
  if ($('#project-side-nav').length){
    var cont = $('#content .container');
    var bottom = cont.offset().top + cont.outerHeight();
    $('#project-side-nav').data('affix-bottom', bottom);
  }
}

function updateAffix(top, bottomB, bottomT, w, el){
  // console.log(top);
  var y = w.scrollTop();
  var x = y + w.height();
  // console.log(x);
  if (y >= top) {
    if (!el.hasClass('affix')) {
      el.addClass('affix');
      el.trigger('affix-on');
    }
    if (bottomB) {
      if (x > bottomB) {
        if (y > bottomT) {
          if (!el.hasClass('affix-bottom')) {
            el.addClass('affix-bottom');
            el.trigger('affix-bottom-on');
          }
        } else {
          if (el.hasClass('affix-bottom')) {
            el.removeClass('affix-bottom');
            el.trigger('affix-bottom-off');
          }
        }
      }
    }
  } else {
    if (el.hasClass('affix')) {
      el.removeClass('affix');
      el.trigger('affix-off');
    }
  }
}

// affixes .affixable
var affixDivs = function affixDivs(fixedEl){
  var $window = $(window);
  $.each(fixedEl, function(){
    var $this = $(this);
    if ($this.hasClass('affix-bottom')) {
      $this.removeClass('affix-bottom');
      $this.trigger('affix-bottom-off');
    }
    if ($this.hasClass('affix')) {
      $this.removeClass('affix');
      $this.trigger('affix-off');
    }
    var top = parseInt($(this).offset().top - (parseFloat(this.style.top) || 0));
    var bottomB, bottomT;
    if ($this.data('affix-bottom')) {
      bottomB = $this.data('affix-bottom');
      bottomT = bottomB - $this.outerHeight() - parseInt($this.css('top'));
    }
    // console.log('TOP', top);
    // console.log('bottomB', bottomB);
    // console.log('bottomT', bottomT);
    updateAffix(top, bottomB, bottomT, $window, $this);
    $window.on('scroll.affix',function(){
      updateAffix(top, bottomB, bottomT, $window, $this);
    });
  });
};

var updatedScrollEventHandlers = function updatedScrollEventHandlers(){
  if ($('#scroll-nav').length){
    $('body').scrollspy('refresh');
  }
  var fixedEl = $('.affixable');
  if (fixedEl.length){
    $(window).off('scroll.affix');
    setAffixableBottom();
    affixDivs(fixedEl);
  }
};

function fetchHelloWorld() {
  var ref;

  var parser = document.createElement('a');
  parser.href = document.referrer;
  var shown = Cookies.get('showedHelloWorld');

  if (!shown && (!document.referrer.length || parser.hostname != window.location.hostname)) {
    var ref = 'default';

    if (parser.hostname && parser.hostname != window.location.hostname) {
      ref = parser.hostname;
    }

    // search GET params
    var params = window.location.search.replace('?', '').split('&');
    for (var i = 0; i < params.length; i++) {
      var tmp = params[i].split('=');
      if (tmp[0] == 'ref') {
        ref = decodeURIComponent(tmp[1]);
        break;
      }
    }

    $.ajax({
      url: '/hello_world',
      data: { ref: ref }
    }).done(function(response){
      $('body').prepend(response.content);
      showHelloWorld();
    });
  }
}

function showHelloWorld() {
  Cookies.set('showedHelloWorld', true, { expires: 30 });
  $('#hello-world').fadeIn(100, function(){
    updatedScrollEventHandlers();
    var content = $('#hello-world .content');
    var height = 100 - content.height();
    $(this)
      .css('padding-top', height / 2)
      .find('.content').css('opacity', 1);
  });
}

// document.ready initializes too early and it messes the dimensions used in the following functions
$(window).load(function(){
  updatedScrollEventHandlers();
  loadSlickSlider({lazyLoad: 'ondemand'});
});

// lazy image load functions
// not exactly lazy anymore, but loads after the page is ready; lazy loading
// wouldn't work quite properly, and it didn't seem to save much bandwidth either
function loadImage (el) {
  el = $(el);
  if (el.hasClass('loaded')) return;

  var img = new Image(),
      src = el.data('async-src');

  img.onload = function() {
    el.attr('src', src);
    el.removeClass('loading');
    el.addClass('loaded');
  }
  img.onerror = function() {
    el.removeClass('loading');
    el.addClass('load-error');
  }

  el.addClass('loading');
  img.src = src;
  el.removeAttr('data-async-src');
}

var lazyLoadImages = function(){
  var query = $('img[data-async-src]');

  query.each(function(i, el){
    loadImage(el);
  });
};
// end - lazy image load functions

$(function () {
  lazyLoadImages();

  $('#project-side-nav')
    .on('affix-bottom-on', function(e){
      var top = $('#content .container').outerHeight() - $(this).outerHeight();
      $(this).css('top', top);
    })
    .on('affix-bottom-off', function(e){
      $(this).css('top', $(this).data('top'));
    });

  // bypass bootstrap .close so we can add callback
  $('body').on('click', '#hello-world .close', function(e){
    $($(this).data('target')).slideUp(200, function(){
      updatedScrollEventHandlers();
    });
  });

  $('body').on('change', '.form-save-on-input', function(e){
    e.preventDefault();
    var that = $(this);
    that.find('select').each(function(i, el) {
      el = $(el);
      var val = $(el).val();
      el.find('option').removeAttr('selected');
      el.val(val);
      el.find('option[value="' + val + '"]').attr('selected', 'selected');
    });
    that.submit();
  });

  $('body')
    .on('ajax:beforeSend', '.form-save-on-input', function(){
      $('body').addClass('app-loading');
    })
    .on('ajax:success', '.form-save-on-input', function(){
      var popover = $(this).closest('.popover');
      var id = popover.attr('id');
      var a = $('[aria-describedby="' + id + '"]');
      var html = popover.find('.popover-content').html();
      a.attr('data-content', html);
    })
    .on('ajax:complete', '.form-save-on-input', function(){
      $('body').removeClass('app-loading');
    });

  $('body')
    .on('ajax:complete', '#project-form-prepublish', function(){
      var select = $(this).find('[name="base_article[content_type]"]');
      if (select.val().length) {
        $('.content-type-indicator').addClass('content-type-present');
        $('.content-type-indicator').removeClass('content-type-missing');
        $('.project-type').text(select.find('option:selected').text());
      } else {
        $('.content-type-indicator').addClass('content-type-missing');
        $('.content-type-indicator').removeClass('content-type-present');
      }
    });

  if ($('body').data('user-signed-in')) {
    doUserSignedInUpdate();
  } else {
    $('.user-signed-out').show();
  }

  if ($('.ab-test').length) {
    $('.ab-test').each(function(i, el){
      el = $(el);
      // the double ajax call, and in particular the ping, is a hack to force
      // the browser to set the correct session, which allows us to correctly
      // track whether the experiment was completed
      $.ajax({
        url: '/ping',
        success: (function(response){
          $.ajax({
            url: '/ab_test',
            data: { experiment: el.data('experiment') },
            success: function(response) {
              el.find('.ab-test-placeholder').text(response.alternative);
            }
          });
        })
      });
    });
  }

  showAlerts();

  $('#show-login-form, .show-login-form').on('click', function(e){
    e.preventDefault();
    openModal('#login-popup');
  });

  $('#show-login-form, .show-simplified-signup').on('click', function(e){
    if (!$('.user-form [name="authenticity_token"]').length) {
      $.ajax({
        url: Utils.getApiPath() + '/private/csrf',
        dataType: 'text',
        xhrFields: {
          withCredentials: true
        },
        success: function(token) {
          var input = $('<input type="hidden" name="authenticity_token" />');
          input.val(token);
          $('.user-form').append(input);
        }
      });
    }
  });

  $('#login-form, #signup-popup-email, #challenge-unlock-form').on('submit', function(e){
    var form = $(this);
    if (!form.find('[name="authenticity_token"]').length) {
      e.preventDefault();
      $.ajax({
        url: Utils.getApiPath() + '/private/csrf',
        dataType: 'text',
        xhrFields: {
          withCredentials: true
        },
        success: function(token) {
          var input = $('<input type="hidden" name="authenticity_token" />');
          input.val(token);
          $('.user-form').append(input);
          form.submit();
        }
      });
    }
  });

  $('input, textarea').placeholder();

  $('form.disable-on-submit').submit(function(e){
    $(this).find('input[name="commit"]').prop('disabled', 'disabled');
  });

  $(document).on('click', '.btn-close', function(e){
    target = $(this).data('close');
    effect = $(this).data('effect') || 'slide';
    if (effect == 'fade') {
      $(target).fadeOut(100);  //after closing alerts/fade-in notices, we need to update the scroll handlers
    } else {
      $(target).slideUp(100);  //after closing alerts/fade-in notices, we need to update the scroll handlers
    }
    e.stopPropagation();
    return false;
  });

  $(document).on('click', '.btn-open', function(e){
    target = $(this).data('open');
    $(target).slideDown(100);
    e.stopPropagation();
    return false;
  });

  $(document).on('click', '.btn-cancel', function(e){
    btn = $(this);
    $(btn.data('hide')).fadeOut(function(){
      $(btn.data('hide')).off();
      $(btn.data('show')).fadeIn();
    });
    e.stopPropagation();
    return false;
  });

  $(document).on('click', '.disable-link', function(e){
    $(this).addClass('disabled-link');
    $(this).html('<i class="fa fa-spinner fa-spin"></i>');
    $(this).on('click', function(e){
      e.preventDefault();
      e.stopPropagation();
    });
  })

  // show notification tooltip if any
  $('#notifications .istooltip').tooltip('show');
  window.setTimeout(function(){
    $('#notifications .istooltip').tooltip('destroy');
  }, 5000);

  $('.collapsible a.toggle').click(function(e){
    e.preventDefault();
    $(this).parent().toggleClass('collapsed');
    $(this).parent().toggleClass('expanded');
    return false;
  });

  $('body').on('click', '.social-share-link', function(e){
    e.preventDefault();
    var url = $(this).data('url');
    window.open(url, '_blank').focus();
  });


  // handling nested forms
  window.NestedFormEvents.prototype.insertFields = function(content, assoc, link) {
    if ($(link).hasClass('nested-field-table')) {
      var $tr = $(link).closest('tr');
      content = content.replace(/^<div class="fields">/, '<tr class="fields">');
      content = content.replace(/<\/div>$/, '</tr>');
      return $(content).insertBefore($tr);
    } else {
      return $(content).insertBefore($(link));
    }
  }

  $('form.sortable').on('nested:fieldAdded', function(e){
    var field = e.field;
    previousPosition = field.prev().find('input.position').val();
    if (isNaN(previousPosition)) previousPosition = 0;
    positionField = field.find('input.position');
    positionField.val(parseInt(previousPosition) + 1);
  });

  $('form.sortable').on('nested:fieldRemoved', function(e){
    e.field.addClass('removed');
    resetSortablePositions($(e.field.parent()));
  });

  sortTable();

  //[data-remote="true"]
  $(document)
    .on("ajax:beforeSend", 'form.remote', function(xhr, settings){
      var $submitButton = $(this).find('input[name="commit"]');

      // Update the text of the submit button to let the user know stuff is happening.
      // But first, store the original text of the submit button, so it can be restored when the request is finished.
      $submitButton.data('origText', $submitButton.val());
      $submitButton.val('Submitting...');
      $submitButton.prop('disabled', true);
    })

    .on("ajax:success", 'form.remote', function(xhr, data, status){
      var $form = $(this);

      // Reset fields and any validation errors, so form can be used again, but leave hidden_field values intact.
      $(this).find('.form-group').find('.error-message').remove();
      $(this).find('.form-group').removeClass('has-error');

      if (data.redirect_to) {
        window.location.replace(data.redirect_to);
      }
    })
    .on('ajax:complete', 'form.remote', function(xhr, status){
      var $submitButton = $(this).find('input[name="commit"]');

      // Restore the original submit button text
      $submitButton.val($submitButton.data('origText'));
      $submitButton.prop('disabled', false);
    })

    .on("ajax:error", 'form.remote', function(error, xhr, status){
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

      // Reset fields and any validation errors, so form can be used again, but leave hidden_field values intact.
      $(this).find('.form-group').find('.error-message').remove();
      $(this).find('.form-group').removeClass('has-error');

      for (model in errors) {
        for (attribute in errors[model]) {
          // transforms attribute name for nested attributes
          var attrName = attribute;
          if (attribute.indexOf('.') != -1) {
            var attributes = attribute.split('.');
            var nested = attributes[0];
            nested += '_attributes';
            var all = [nested];
            for (var i = 1; i < attributes.length; i++) {
              all.push(attributes[i]);
            }
            attribute = all.join('][');
          }
          var input = $form.find('[name="' + model + '['+attribute+']"]').first();
          // sometimes they have [] in the name
          if (input.length == 0) input = $form.find('[name="' + model + '['+attribute+'][]"]').first();
          input.parents('.form-group').addClass('has-error');
          errorMsg = $('<span class="help-block error-message">' + errors[model][attrName] + '</span>');
          if (input.parent().hasClass('input-group')) {
            errorMsg.insertAfter(input.parent());
          } else {
            errorMsg.appendTo(input.parent());
          }
        }
      }
    });

  if ($('.navbar-tabs').length) {
    // handle tabs navigation with URL
    var hash = document.location.hash;
    // var prefix = "#tab-";
    var prefix = '#';
    if (hash) {
      $('.navbar-tabs a[href=' + prefix + hash.replace('#', '') + ']').tab('show');
      history.pushState(null, null, window.location.href);
    }
    // navigate to a tab when the history changes
    window.addEventListener("popstate", function(e) {
      hash = document.location.hash;
      var activeTab = $('[href=' + prefix + hash.replace('#', '') + ']');
      if (activeTab.length) {
        activeTab.tab('show');
      } else {
        $('.navbar-tabs a:first').tab('show');
      }
    });

    // Change hash for page-reload
    $('.navbar-tabs a').on('shown.bs.tab', function (e) {
      var scroll = $(window).scrollTop();
      window.location.hash = e.target.hash.replace(prefix, "#");
      $(window).scrollTop(scroll);
    });
  }

  $('a.smooth-scroll').on('click', function(e){
    target = '#' + this.hash.substring(1);
    offset = $(this).data('offset') || 0;
    if ($(target).length) {
      e.preventDefault();
      smoothScrollTo(target, offset);
    }
  });

  if ($('#signup-popup').length) {
    showSignupPopupOrNot();
  }

  $('.hljs-active :not(.highlight) > pre').each(function(i, block) {
    hljs.highlightBlock(block);
  });

  $('#signup-popup').on('modal:open', function(e){
    $(this).find('input:visible').first().focus();
  });

  updateProjectThumbLinks();
});

function closeNav(nav) {
  nav.slideUp(function(){
    $(this).prev().slideDown();
  });
}

// show popup if cookie doesn't exist or expired
// create cookie or update it with expiration date in 24 hours
function showSignupPopupOrNot() {
  var val = Cookies.get('showedSignupPopup');
  if (val) val = parseInt(val);
  if (!val || val % 5 == 0) {
    val = 0;
    Cookies.set('showedSignupPopup', val, { expires: 1 });
  } else if (val == 1) {
    // show on scroll to make sure they're on the page
    $window = $(window);
    $window.on('scroll.showSignupPopup', function(){
      $window.off('scroll.showSignupPopup');
      window.setTimeout(function() {
        openModal('#signup-popup');
      }, 100);
    });
  }
  Cookies.set('showedSignupPopup', val + 1);
}

function smoothScrollToIfOutOfBounds(target, offsetTop, speed) {
  if (typeof(target) == 'string') target = $(target);
  var top = window.pageYOffset || document.documentElement.scrollTop,
      bottom = top + $(window).height(),
      targetPos = target.offset().top;
  if ((targetPos + target.height() > bottom) || (targetPos + offsetTop < top))
    smoothScrollTo(target, offsetTop, speed);
}

function smoothScrollToAndHighlight(target, offsetTop, hiliTarget) {
  smoothScrollTo(target, offsetTop);
  if (typeof(hiliTarget) == 'string') hiliTarget = $(hiliTarget);
  $('.highlight-flash').removeClass('highlight-flash');
  hiliTarget.addClass('highlight-flash-transition');
  hiliTarget.addClass('highlight-flash');
  window.setTimeout(function(){
    hiliTarget.removeClass('highlight-flash');
  }, 3000);
}

function smoothScrollToBottom(target, offsetBottom, speed) {
  offsetBottom = offsetBottom || 0;
  if (typeof(target) == 'string') target = $(target);
  offsetTop = -($(window).height() - target.height() - offsetBottom);
  smoothScrollTo(target, offsetTop, speed);
}

function smoothScrollTo(target, offsetTop, speed) {
  offsetTop = offsetTop || 0;
  speed = speed || 500;
  if (typeof(target) == 'string') target = $(target);
  $('html, body').stop().animate({
    'scrollTop': target.offset().top + offsetTop
  }, speed, 'swing', function () {});
  return target;
}

function updateProjectThumbLinks() {
  // update thumbnail links for projects
  $(".project-thumb-container.has-data:not(.link-added)").each(function(i, project){
    project = $(project);
    ref = project.data('ref');
    refId = project.data('ref-id');
    offset = project.data('offset');
    $('a.project-link-with-ref', this).each(function(j, link) {
      href = link.getAttribute('href') || link.href;
      link.href = href + "?ref=" + ref + "&ref_id=" + refId + "&offset=" + offset;
    });
    project.addClass('link-added');
  });
}

function closePopup(id) {
  $(id).fadeOut(200);
  return false;
}

function doUserSignedInUpdate(){
  $('.user-signed-in').show();
  var csrf = $('meta[name="csrf-token"]').attr('content');
  var input = $('<input type="hidden" name="authenticity_token" />');
  input.val(csrf);
  $('form.append-csrf-token').append(input);
}

function sortTable(){
  $('form.sortable .table-sortable tbody')
    .sortable({
      axis: 'y',
      handle: ".handle",
      containment: 'parent',
      items: 'tr:not(.sortable-disabled)',
      placeholder: "sortable-placeholder",
      helper: function(e, el){
        var copy = $(el).clone();
        copy.addClass('sortable-helper');
        return copy;
      },
      tolerance: 'pointer'
    })
    .bind('sortupdate', function(e, ui) {
      resetSortablePositions($(e.target));
    });
}

function resetSortablePositions(target){
  var target = target || $('form.sortable .table-sortable tbody');
  target.find('tr:not(.removed) input.position').each(function(i){
    $(this)
      .val(i+1)
      .trigger('change');
  });
}

function showAlerts() {
  var alert = $('.alert-top');
  var right = - alert.outerWidth() - 1;
  alert.css('right', right + 'px');
  window.setTimeout(function(){
    alert.removeClass('alert-hidden');
    alert.css('right', '');
    window.setTimeout(function(){
      alert.css('right', right + 'px');
    }, 5000);
  }, 100);
}