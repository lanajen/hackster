$(document).ready(function(){
  $('.project-show .well').on('keypress', '#new_comment textarea', function(event){
    if (event.which == 13 && !event.shiftKey) {
      event.preventDefault();
      $(this).parents('form').submit();
    }
  });

  // auto adjust the height of
  $('.project-show .well').on('keyup keydown', '#new_comment textarea', function(){
    var t = $(this);
    var h = t[0].scrollHeight - parseInt(t.css('padding-top')) - parseInt(t.css('padding-bottom'));
    t.height(21).height(h);  // where 21 is the minimum height of textarea (25 - 4 for padding)
  });

  $('.issue-content').on('click', '.issue-comment-cancel', function(e){
    e.preventDefault();
    $($(this).data('target')).replaceWith($(this).data('template'));
  });
});