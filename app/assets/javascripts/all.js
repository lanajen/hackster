$(function () {
  $('input, textarea').placeholder();

  $('form.disable-on-submit').submit(function(){
    $(this).find('input[name="commit"]').prop('disabled', 'disabled');
  });

  // affixes .affixable
  var $fixedEl;
  var affixDivs = function affixDivs(){
    $fixedEl = $('.affixable');
    var $window = $(window);
    if ($fixedEl.length) {
      $.each($fixedEl, function(){
        var top = parseInt($(this).offset().top - (parseFloat($(this).css('top')) || 0)),
            $this = $(this);
        updateAffix(top, $window, $this);
        $window.on('scroll.affix',function(){
          updateAffix(top, $window, $this);
        });
      });
    }
  };

  function updateAffix(top, w, el){
    var y = w.scrollTop();
    if (y >= top) {
      el.hasClass('affix') ? '' : el.addClass('affix');
    } else {
      el.hasClass('affix') ? el.removeClass('affix') : '';
    }
  }

  //Fade in alerts/notices
  if($('.fade-in').length){
    //if there's a slide-in notification on top of the page, wait until it's down sliding down before affixing divs
    $('.fade-in').delay(2000).slideDown(500,function(){
      affixDivs();
    });
  } else{
    affixDivs();
  }

  $(document).on('click', '.btn-close', function(e){
    target = $(this).data('close');
    effect = $(this).data('effect') || 'slide';
    if (effect == 'fade') {
      $(target).fadeOut(100,updatedScrollEventHandlers);  //after closing alerts/fade-in notices, we need to update the scroll handlers
    } else {
      $(target).slideUp(100,updatedScrollEventHandlers);  //after closing alerts/fade-in notices, we need to update the scroll handlers
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

  //[data-remote="true"]
  $(document)
    .on("ajax:beforeSend", 'form', function(evt, xhr, settings){
      var $submitButton = $(this).find('input[name="commit"]');

      // Update the text of the submit button to let the user know stuff is happening.
      // But first, store the original text of the submit button, so it can be restored when the request is finished.
      $submitButton.data( 'origText', $(this).text() );
      $submitButton.text( "Submitting..." );

    })
    .on("ajax:success", 'form', function(evt, data, status, xhr){
      var $form = $(this);

      // Reset fields and any validation errors, so form can be used again, but leave hidden_field values intact.
      $('.form-group').find('.help-inline').remove();
      $('.form-group').removeClass('has-error');

      // Insert response partial into page below the form.
      $('#comments').append(xhr.responseText);

    })
    .on('ajax:complete', 'form', function(evt, xhr, status){
      var $submitButton = $(this).find('input[name="commit"]');

      // Restore the original submit button text
      $submitButton.text( $(this).data('origText') );
    })
    .on("ajax:error", 'form', function(evt, xhr, status, error){
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
      $('.has-error .help-block.error-message').remove();
      $('.form-group').removeClass('has-error');

      for (model in errors) {
        for ( error in errors[model] ) {
          input = $form.find('[name="' + model + '['+error+']"]');
          input.parents('.form-group').addClass('has-error');
          errorMsg = $('<span class="help-block error-message">' + errors[model][error] + '</span>');
          if (input.parent().hasClass('input-group')) {
            errorMsg.insertAfter(input.parent());
          } else {
            errorMsg.insertAfter(input);
          }
        }
      }
    });

  // handle tabs navigation with URL
  var hash = document.location.hash;
  var prefix = "nav-";
  if (hash) {
    $('.navbar-tabs a[href='+hash.replace(prefix,"")+']').tab('show');
    history.pushState(null, null, window.location.href);
  }
  // navigate to a tab when the history changes
  window.addEventListener("popstate", function(e) {
    hash = document.location.hash;
    var activeTab = $('[href=' + hash.replace(prefix,"") + ']');
    if (activeTab.length) {
      activeTab.tab('show');
    } else {
      $('.navbar-tabs a:first').tab('show');
    }
  });

  // Change hash for page-reload
  $('.navbar-tabs a').on('shown.bs.tab', function (e) {
      window.location.hash = e.target.hash.replace("#", "#" + prefix);
  });

  // update thumbnail links for projects
  $(".project-thumb-container.has-data").each(function(i, project){
    project = $(project);
    ref = project.data('ref');
    refId = project.data('ref-id');
    offset = project.data('offset');
    $('a.project-link-with-ref', this).each(function(j, link) {
      href = link.href;
      link.href = href + "?ref=" + ref + "&ref_id=" + refId + "&offset=" + offset;
    });
  });

  var updatedScrollEventHandlers = function updatedScrollEventHandlers(){
    if ($('#scroll-nav').length){
      $('body').scrollspy('refresh');
    }
    if ($fixedEl.length){
      $(window).off('scroll.affix');
      affixDivs();
    }
  };

  if ($('.popup-overlay').length) {
    $('.popup-overlay-bg').click(function(){
      $('.popup-overlay').fadeOut(200);
    });
  }
});

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
  $('.highlight').removeClass('highlight');
  hiliTarget.addClass('highlight-transition');
  hiliTarget.addClass('highlight');
  window.setTimeout(function(){
    hiliTarget.removeClass('highlight');
  }, 3000);
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

function closePopup(id) {
  $(id).fadeOut(200);
  return false;
}