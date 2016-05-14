/** Global Utils | Exposed in components.js via babel */

import jwtDecode from 'jwt-decode';
import request from 'superagent';

function requestToken() {
  return new Promise((resolve, reject) => {
      request
        .get(`/users/api_token`)
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
          token = response.body.token;
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