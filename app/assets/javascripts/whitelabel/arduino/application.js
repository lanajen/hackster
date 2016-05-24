//= require whitelabel/arduino/jquery-ui
//= require whitelabel/arduino/jquery.dotdotdot
//= require whitelabel/arduino/barbecue

$(function() {
  $(".ellipsis").dotdotdot();

  // sign out hijack to clear up local storage
  $('.sign-out-link').on('click', function(e){
    e.preventDefault();

    // clear up arduino local storage
    window.localStorage.removeItem('ideapp.token');
    window.localStorage.removeItem('ideapp.uid');
    window.localStorage.removeItem('ideapp.email');
    // renaming of keys in progress
    window.localStorage.removeItem('create.token');
    window.localStorage.removeItem('create.uid');
    window.localStorage.removeItem('create.email');

    Cookies.remove('web.ide.sid');

    // sign out
    $('#sign-out-form').submit();
  });
});