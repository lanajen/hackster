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

    // sign out from arduino
    $.ajax({
      url: 'https://id.arduino.cc/cas/logout?service=https://create.arduino.cc/'
    }).complete(function(){  // use complete so that it fires whatever the output of above, so that the click on the signout button works as expected
      // sign out
      $('#sign-out-form').submit();
    });
  });
});