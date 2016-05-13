/** Global Utils | Exposed in components.js via babel */

import jwtDecode from 'jwt-decode';
import request from 'superagent';

function requestToken() {
  return new Promise((resolve, reject) => {
      request
        .get(`/oauth/authorize`)
        .query({client_id: '9b244782686b5900edfd87611f049bc90b080ab114e3436462b1874ab3e37a95'})
        .query({redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'})
        .query({scope: 'profile read_public read_private'})
        .query({response_type: 'token'})
        .query({state: 'b4f3077619eb7f0656690aace62af5859d74b8cec86e8bfe'})
        .withCredentials()
        .end(function(err, res) {
          if (err) {
           reject(err);
           } else {
            window.setTimeout(function() { resolve(res) }, 3000);
          }
          // err ? reject(err) : resolve(err);
        });
    });
}

let apiTokenCallbacks = [];

function resolveApiTokenCallbacks(token) {
  apiTokenCallbacks.forEach(function(callback){
    callback(token);
  });
  apiTokenCallbacks = [];
}

// class ApiTokenCallback {
//   static callbacks = [];

//   constructor() {
//   }

//   addCallback(callback) {
//     callbacks.push(callback);
//   }

//   getCallback() {
//     return callbacks;
//   }

//   resolveCallbacks(token) {
//     callbacks.map(function(callback){
//       callback(token);
//     });
//     callbacks = [];
//   }
// }

const Utils = {
  getApiPath() {
    if(window && window.location) {
      const protocol = window.location.protocol;
      const port = window.location.port;
      const element = document.getElementById('api-uri');

      return element && element.content && port && port.length
        ? `${protocol}//${element.content}:${port}`
        : element && element.content
        ? `${protocol}//${element.content}`
        : console.error('Utils.getApiPath expects a meta tag with an id of api-uri');
    }
  },

  getApiToken(callback) {
    apiTokenCallbacks.push(callback);

    if (window && window.localStorage) {
      let token = window.localStorage.getItem('hackster.apiToken');
      if (token) {
        const timeNow = Math.round(new Date() / 1000);
        const jwt = jwtDecode(token);
        const jwtExp = jwt.exp;
        // 10 seconds buffer
        if (jwtExp && jwtExp - 10 > timeNow) {
          // token valid
          return resolveApiTokenCallbacks(token);
        }
      }

      // token invalid or doesn't exist
      return requestToken()
        .then(function(response){
          token = response.xhr.responseURL.split('?')[1].split('=')[1];
          // window.localStorage.setItem('hackster.apiToken', token);
          return resolveApiTokenCallbacks(token);
        })
        .catch(function(err) { console.log('Request Error: ' + err); });
    }
  },

  getCSRFToken() {
    let metaList = document.getElementsByTagName('meta');
    let csrfToken;

    [].slice.call(metaList).forEach(m => {
      if(m.name === 'csrf-token' && m.content) { csrfToken = m.content }
    });

    return csrfToken;
  }
}

export default Utils;