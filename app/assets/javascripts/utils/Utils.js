/** Global Utils | Exposed in components.js via babel */

export default {
  getApiPath() {
    if(window && window.location) {
      let protocol = window.location.protocol;
      let port = window.location.port;
      return port && port.length ? `${protocol}//${document.getElementById('api-uri').content}:${port}` : `${protocol}//${document.getElementById('api-uri').content}`;
    }
  },

  getCSRFToken() {
    let metaList = document.getElementsByTagName('meta');
    let csrfToken;

    [].slice.call(metaList).forEach(m => {
      if(m.name === 'csrf-token') { csrfToken = m.content }
    });

    return csrfToken;
  }
}