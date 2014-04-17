$(document).ready(function(){
  $('.project-show .well').on('keypress', '#new_comment textarea', function(){
    if (event.which == 13 && !event.shiftKey) {
      event.preventDefault();
      $(this).parents('form').submit();
    }
  });

  // auto adjust the height of
  $('.project-show .well').on('keyup keydown', '#new_comment textarea', function(){
    var t=$(this);
    t.height(15).height(t[0].scrollHeight);//where 15 is minimum height of textarea
  });

  // auto adjust the height of
  $('.project-show .well').on('focus', '#new_comment textarea', function(){
    $(this).tooltip('show');
  });

  // auto adjust the height of
  $('.project-show .well').on('focusout', '#new_comment textarea', function(){
    $(this).tooltip('destroy');
  });

  $('.issue-content').on('click', '.issue-comment-cancel', function(e){
    e.preventDefault();
    $($(this).data('target')).replaceWith($(this).data('template'));
  });
});