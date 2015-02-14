function openModal(id) {
  var p = $(id).find('.popup-overlay-inner');
  var defaultWidth = parseInt($(id).data('width')) || 600;
  var width = window.innerWidth * 0.9 > defaultWidth ? defaultWidth : window.innerWidth * 0.9;
  p
    .css('width', width)
    .css('margin-left', -(p.outerWidth() / 2))
  $(id).fadeIn(200);
  p.css('margin-top', -(p.height() / 2));
  return false;
}

function closeModal(id) {
  $(id).fadeOut(200, function(){
    if ($(this).hasClass('modal-remove')) $(this).remove();
  });
  return false;
}

$(function () {
  $('.modal-popup.modal-show').each(function(i, el) {
    var id = $(el).attr('id');
    window.setTimeout(function(){
      openModal('#' + id);
    }, 2000);
  });

  $('body').on('click', '.modal-popup .close', function(e){
    e.preventDefault();
    var target = $(this).data('target');
    closeModal(target);
  });

  $('body').on('click', '.modal-open', function(e){
    var target = $(this).data('target');
    openModal(target);
  });

  $(document).ajaxComplete(function(event, request) {
    var alertHtml = request.getResponseHeader('X-Alert');
    var id = request.getResponseHeader('X-Alert-ID');

    if (typeof(alertHtml) != 'undefined') {
      $(alertHtml).appendTo('body');
      openModal(id);
    }
  });

  $('body').on('click', '.modal-popup .popup-overlay-bg', function(e){
    e.preventDefault();
    closeModal('#' + $(this).parent().attr('id'));
  });
});