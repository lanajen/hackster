function openModal(id, button) {
  $('.modal-popup:not(' + id  + ')').each(function(i, el){
    closeModal('#' + $(el).attr('id'));
  });
  $(id).trigger({ type: 'modal:opening', relatedTarget: button });
  resizeModal(id);
  return false;
}

function resizeModal(id) {
  var m = $(id);
  var p = m.find('.popup-overlay-inner');
  var defaultWidth = parseInt($(id).data('width')) || 600;
  var width = window.innerWidth * 0.9 > defaultWidth ? defaultWidth : window.innerWidth * 0.9;
  p
    .css('width', width)
    .css('margin-left', -(p.outerWidth() / 2))

  m.fadeIn(200, function(){
    $('body').addClass('modal-open');
    m.trigger('modal:open');
  });

  var height = Math.max(-(p.height() / 2), -($(window).height() / 2 - 20));  // 20 for padding
  p.css('margin-top', height);
}

function closeModal(id) {
  var m = $(id);
  m.trigger('modal:closing');
  m.fadeOut(200, function(){
    if ($(this).hasClass('modal-remove')) $(this).remove();
    m.trigger('modal:closed');
  });
  $('body').removeClass('modal-open');
  return false;
}

$(function () {
  var body = $('body');
  var target;

  $('.modal-popup.modal-show').each(function(i, el) {
    var id = $(el).attr('id');
    window.setTimeout(function(){
      openModal('#' + id);
    }, 2000);
  });

  body.on('click', '.modal-popup .close, .modal-popup .close-btn', function(e){
    e.preventDefault();
    target = $(this).data('target');
    closeModal(target);
  });

  body.on('click', '.modal-open', function(e){
    e.preventDefault();
    target = $(this).data('target');
    openModal(target);
  });

  $(document).ajaxComplete(function(event, request) {
    var alertHtml = request.getResponseHeader('X-Alert');
    var id = request.getResponseHeader('X-Alert-ID');

    if (typeof(alertHtml) != 'undefined' && typeof(id) != 'undefined' && alertHtml && id) {
      $(alertHtml).appendTo('body');
      openModal(id);
    }
  });

  body.on('click', '.modal-popup .popup-overlay-bg:not(.disable-click)', function(e){
    e.preventDefault();
    closeModal('#' + $(this).parent().attr('id'));
  });
});