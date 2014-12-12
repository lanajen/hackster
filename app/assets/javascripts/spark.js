/*
1. create an auth token for hackster (enter spark creds and save returned token)
2. select device in list
3. confirm
4. flash
5. return output (either success or couldn't connect)

*/

$('#spark-upload').on('submit', function(e){
  e.preventDefault();

  var code = $(this).find('[name="code"]').val();
  var deviceId = $(this).find('[name="deviceId"]').val()
  var authToken = getAccessToken();
  var submit = $(this).find('[type="submit"]');

  if (deviceId != '') {
    if (submit.val() == 'Upload this sketch') {
      submit.val('Click again to confirm');
    } else {
      flashSparkCore(authToken, deviceId, code);
    }
  } else {
    alert('Please select a device!');
  }
})

function flashSparkCore(authToken, deviceId, code) {
  var data = new FormData();
  data.append('file', code);

  $.ajax({
    url: 'https://api.spark.io/v1/devices/' + deviceId,
    type: 'PUT',
    data: data,
    cache: false,
    dataType: 'json',
    processData: false, // Don't process the files
    contentType: false,
    headers: {
      'Authorization' : 'Bearer ' + authToken
    }, success: function(data){
      if (data.ok == 'true') {
        alert('success!');
      } else {
        alert('error! (see console)');
        console.log(data.errors);
      }
    }, error: function(data){
      alert('error! (see console)');
      console.log('status: ' + data.status);
      console.log(data);
    }
  })
}

  function addSparkAccessToken(token){
    $.ajax({
      url: '/spark/authorizations',
      type: 'POST',
      data: { token: token },
      success: function(data){
        setAccessTokenMeta(token);
        window.location = '/spark/authorizations';
      },
      error: function(data){
        console.log('craaash');
      }
    });
  }

  function fetchAccessToken(){
    $.ajax({
      url: '/spark/authorizations/current',
      type: 'GET',
      success: function(data){
        setAccessTokenMeta(data.token);
      }
    });
  }

  function setAccessTokenMeta(token){
    $('<meta name="spark_access_token" content="' + token + '">').appendTo('head');
  }

  function getAccessToken(){
    return $('meta[name="spark_access_token"]').attr('content');
  }

  function getDevices(){
    var token = getAccessToken();

    $.ajax({
      url: 'https://api.spark.io/v1/devices',
      type: 'GET',
      headers: { 'Authorization': "Bearer " + token },
      success: function(data){
        if (data.length > 0) {
          $.each(data, function(i, value){
            $('<option value="' + value + '">' + value + '</option>').appendTo('#devices');
            $('#spark-upload').show();
          });
        } else {
          $('#spark-upload').replaceWith('<p>You have no devices</p>');
        }
      }
    });
  }