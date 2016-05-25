import jwtDecode from 'jwt-decode';
import request from 'superagent';

const tokenKeyPrefix = 'hck.tkn';
const clientToken = tokenKeyPrefix + '.client';
const userToken = tokenKeyPrefix + '.user';
let callbackQueue = [];

function fetchToken() {
  return new Promise((resolve, reject) => {
    request
      .get(`/projecthub/users/api_token`)
      .withCredentials()
      .end(function(err, res) {
        err ? reject(err) : resolve(res.body);
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

function getToken(withUser) {
  return window && window.localStorage
    ? (withUser ? getFromLocalStorage(userToken) : getFromLocalStorage(userToken, clientToken))
    : document && document.cookie
    ? parseCookie(withUser)
    : null;
}

function getFromLocalStorage(key1, key2) {
  return window.localStorage.getItem(key1) || window.localStorage.getItem(key2);
}

function parseCookie(withUser) {
  const cookieMap = document.cookie.split(';').reduce((acc, curr) => {
    const cookie = curr.split('=');
    acc[cookie[0]] = cookie[1];
    return acc;
  }, {});

  return (withUser ? cookieMap[userToken] : cookieMap[userToken] || cookieMap[clientToken]) || null;
}

function setTokens(tokens) {
  if (window && window.localStorage) {
    window.localStorage.setItem(clientToken, tokens.client_token);
    if (tokens.user_token)
      window.localStorage.setItem(userToken, tokens.user_token);
  } else if (document && document.cookie) {
    let cookieString = `${clientToken}=${tokens.client_token}`;
    if (tokens.user_token) cookieString += `${userToken}=${tokens.user_token}`;
    cookieString += ";path=/";
    document.cookie = cookieString;
  }
}

export default function getApiToken(callback, withUser) {
  const token = getToken(withUser);

  if (token && isTokenValid(token)) {
    return callbackQueue.length ? resolveCallbacks(token) : callback(token);
  }

  callbackQueue.push(callback);

  if(callbackQueue.length === 1) {
    return fetchToken()
      .then(tokens => {
        setTokens(tokens);
        const newToken = tokens.user_token || tokens.client_token;
        resolveCallbacks(newToken);
      })
      .catch(err => console.error('Request Error: ' + err));
  }
}