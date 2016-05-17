import jwtDecode from 'jwt-decode';
import request from 'superagent';

const tokenKey = 'hck_api_token';
let callbackQueue = [];

function fetchToken() {
  return new Promise((resolve, reject) => {
    request
      .get(`/users/api_token`)
      .withCredentials()
      .end(function(err, res) {
        err ? reject(err) : resolve(res.body.token);
      });
  });
}

function isTokenValid(token) {
  const jwt = jwtDecode(token);
  return jwt.exp && ((jwt.exp - 10) >  Math.round(new Date() / 1000));
}

function resolveCallbacks(token) {
  callbackQueue.forEach(callback => callback(token));
  callbackQueue = [];
}

function getToken() {
  return window && window.localStorage
    ? window.localStorage.getItem(tokenKey)
    : document && document.cookie
    ? parseCookie()
    : null;
}

function parseCookie() {
  const cookieMap = document.cookie.split(';').reduce((acc, curr) => {
    const cookie = curr.split('=');
    acc[cookie[0]] = cookie[1];
    return acc;
  }, {});

  return cookieMap[tokenKey] || null;
}

function setToken(token) {
  window && window.localStorage
    ? window.localStorage.setItem(tokenKey, token)
    : document && document.cookie
    ? document.cookie = `${tokenKey}=${token};path=/`
    : null;
}

export default function getApiToken(callback) {
  const token = getToken();

  if (token && isTokenValid(token)) {
    return callbackQueue.length ? resolveCallbacks(token) : callback(token);
  }

  callbackQueue.push(callback);

  if(callbackQueue.length === 1) {
    return fetchToken()
      .then(newToken => {
        setToken(newToken);
        resolveCallbacks(newToken);
      })
      .catch(err => console.error('Request Error: ' + err));
  }
}