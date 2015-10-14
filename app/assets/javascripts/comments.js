$(document).ready(function(){
  // $('.project-show .well').on('keypress', '#new_comment textarea', function(event){
  //   if (event.which == 13 && !event.shiftKey) {
  //     event.preventDefault();
  //     $(this).parents('form').submit();
  //   }
  // });

  function adjustCommentHeight(t) {
    // var t = $(el);
    var h = t[0].scrollHeight - parseInt(t.css('padding-top')) - parseInt(t.css('padding-bottom'));
    t.height(21).height(h);  // where 21 is the minimum height of textarea (25 - 4 for padding)
  }

  // auto adjust the height of
  $('#conversation').on('keyup keydown', '[name="conversation[body]"]', function(){
    adjustCommentHeight($(this));
  });

  // auto adjust the height of
  $('.comments').on('keyup keydown', '[name="comment[raw_body]"]', function(){
    adjustCommentHeight($(this));
  });

  $('.issue-content').on('click', '.issue-comment-cancel', function(e){
    e.preventDefault();
    $($(this).data('target')).replaceWith($(this).data('template'));
  });
});