$(document).ready(function(){
  $('.btn-cancel').live('click', function(e){
    btn = $(this);
    $(btn.data('hide')).slideUp(function(){
      $(btn.data('show')).slideDown();
    });
    e.stopPropagation();
    return false;
  });
});

$(document).ready(function(){

  //[data-remote="true"]
  $('form')
    .live("ajax:beforeSend", function(evt, xhr, settings){
      var $submitButton = $(this).find('input[name="commit"]');

      // Update the text of the submit button to let the user know stuff is happening.
      // But first, store the original text of the submit button, so it can be restored when the request is finished.
      $submitButton.data( 'origText', $(this).text() );
      $submitButton.text( "Submitting..." );

    })
    .live("ajax:success", function(evt, data, status, xhr){
      var $form = $(this);

      // Reset fields and any validation errors, so form can be used again, but leave hidden_field values intact.
      $('.control-group').find('.help-inline').remove();
      $('.control-group').removeClass('error');

      // Insert response partial into page below the form.
      $('#comments').append(xhr.responseText);

    })
    .live('ajax:complete', function(evt, xhr, status){
      var $submitButton = $(this).find('input[name="commit"]');

      // Restore the original submit button text
      $submitButton.text( $(this).data('origText') );
    })
    .live("ajax:error", function(evt, xhr, status, error){
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

      for ( error in errors ) {
        input = $form.find('[name="user['+error+']"]');
        input.parents('.control-group').addClass('error');
        $('<span class="help-inline">' + errors[error] + '</span>').insertAfter(input);
      }
    });

});