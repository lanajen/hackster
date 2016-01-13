var map, markerClusterer, initialLocation;
// var browserSupportFlag = new Boolean();

function initMap() {
  var mapOpts = {
    zoom: 10,
    maxZoom: 12,
    zoomControl: true,
    mapTypeControl: false,
    scaleControl: false,
    streetViewControl: false,
    rotateControl: false
  }
  map = new google.maps.Map(document.getElementById('map'), mapOpts);

  if (navigator.geolocation) {
    //browserSupportFlag = true;
    navigator.geolocation.getCurrentPosition(function(position) {
      initialLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
      map.setCenter(initialLocation);
    }, function() {
      //handleNoGeolocation(browserSupportFlag);
    });
  }
  // Browser doesn't support Geolocation
  else {
    //browserSupportFlag = false;
    //handleNoGeolocation(browserSupportFlag);
  }

  function handleNoGeolocation(errorFlag) {
    if (errorFlag == true) {
      alert("Geolocation service failed.");
      initialLocation = newyork;
    } else {
      alert("Your browser doesn't support geolocation. We've placed you in Siberia.");
      initialLocation = siberia;
    }
    map.setCenter(initialLocation);
  }

  map.addListener('idle', function() {
    var bounds = map.getBounds();
    if (bounds) {
      var latLng = {
        ne_lat: bounds.N.j,
        ne_lng: bounds.j.N,
        sw_lat: bounds.N.N,
        sw_lng: bounds.j.j
      }
      loadMarkers(latLng);
    }
  });
}

function loadMarkers(latLng) {
  $.ajax({
    type: 'GET',
    url: '/api/v1/users',
    data: latLng
  }).done(function(response){
    printMarkers(response.users);
    loadThumbs(latLng);
  }).fail(function(){
    console.log('failed loading users for markers');
  });
}

$(function(){
  $('#user-list').on('click', '.load-more-users', function(e){
    e.preventDefault();
    $(this).html('<i class="fa fa-spinner fa-spin"></i>');
    var params = $(this).data('params');
    var opts = {};
    _.forEach(params.split('&'), function(kv){
      var k = kv.split('=')[0];
      var v = kv.split('=')[1];
      opts[k] = v;
    });
    loadThumbs(opts, true);
  });
});

function loadThumbs(opts, preserve) {
  opts.load_users = true;
  var userList = $('#user-list');
  if (!preserve)
    userList.html('<div class="user-thumb-gmap text-center"><i class="fa fa-spinner fa-spin"></i></div>');
  $.ajax({
    type: 'GET',
    url: '/api/v1/users',
    data: opts
  }).done(function(response){
    var thumbs = _.map(response.users, function(user){
      var tpl = '<div class="user-thumb-gmap">' +
              '<p class="name">' + '<img src="' + user.avatarUrl + '" class="img-circle" />' +
              '<a class="user-name" href="/' + user.slug + '">' + user.name + '</a></p>' +
              '<p class="location"><i class="fa fa-map-marker"></i><span>' + user.location + '</span>';
      if (user.miniResume && user.miniResume != '') {
        tpl += '<p>' + user.miniResume + '</p>';
      }
      if (_.some(user.interests)) {
        tpl += '<p class="tags-title">Interests:</p><p class="tags">';
        _.forEach(user.interests, function(tag){
          tpl += '<span class="label label-default">' + tag + '</span>';
        });
        tpl += '</p>';
      }
      if (_.some(user.skills)) {
        tpl += '<p class="tags-title">Skills:</p><p class="tags">';
        _.forEach(user.skills, function(tag){
          tpl += '<span class="label label-default">' + tag + '</span>';
        });
        tpl += '</p>';
      }
      tpl += '</div>';
      return tpl;
    });
    var html = preserve ? userList.html() : '';
    html += thumbs.join('');
    opts.page = response.nextPage;
    var params = [];
    _.forEach(opts, function(v, k){
      params.push(k + '=' + v);
    });
    params = params.join('&');
    if (response.nextPage) {
      html += '<div class="user-thumb-gmap">' +
              '<a class="load-more-users btn btn-default btn-block" href="javascript:void(0)" data-params="' + params + '">Load more</a>' +
              '</div>';
    }
    userList.html(html);
    if (preserve) {
      userList.find('.load-more-users').first().parent().remove();
    } else {
      userList.scrollTop(0);
    }
  }).fail(function(){
    console.log('failed loading users for thumbs');
  });
}

function printMarkers(markerData) {
  if (markerClusterer)
    markerClusterer.clearMarkers();

  var markers = [];

  _.map(markerData, function(data){
    var latLng = new google.maps.LatLng(data.lat, data.lng)
    var marker = new google.maps.Marker({
      position: latLng,
      icon: {
        url: 'https://cdn3.iconfinder.com/data/icons/figures/500/One_round_figure_assume_math-24.png',
        anchor: new google.maps.Point(16, 16)
      }
    });

    markers.push(marker);
  });

  markerClusterer = new MarkerClusterer(map, markers, {
    maxZoom: 14,
    gridSize: 40
  });
}