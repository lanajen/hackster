$('input, textarea').placeholder();

$(document).ready(function(){
  $('.fade-in').delay(2000).slideDown(500);
  $(document).on('click', '.btn-close', function(e){
    target = $(this).data('close');
    effect = $(this).data('effect') || 'slide';
    if (effect == 'fade') {
      $(target).fadeOut(100);
    } else {
      $(target).slideUp(100);
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
    $(btn.data('hide')).slideUp(function(){
      $(btn.data('hide')).off();
      $(btn.data('show')).slideDown();
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
      $('.has-error .help-inline').remove();
      $('.form-group').removeClass('has-error');

      for ( error in errors ) {
        input = $form.find('[name="user['+error+']"]');
        input.parents('.form-group').addClass('has-error');
        $('<span class="help-inline">' + errors[error] + '</span>').insertAfter(input);
      }
    });

  // handle tabs navigation with URL
  var hash = document.location.hash;
  var prefix = "nav-";
  if (hash) {
      $('.navbar-tabs a[href='+hash.replace(prefix,"")+']').tab('show');
  }

  // Change hash for page-reload
  $('.navbar-tabs a').on('shown.bs.tab', function (e) {
      window.location.hash = e.target.hash.replace("#", "#" + prefix);
  });
});


function smoothScrollTo(target, offsetTop) {
  offsetTop = offsetTop || 0;
  if (typeof(target) == 'string') target = $(target);
  $('html, body').stop().animate({
    'scrollTop': target.offset().top + offsetTop
  }, 500, 'swing', function () {});
}