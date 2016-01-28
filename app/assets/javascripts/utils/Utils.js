/** Global Utils | Exposed in components.js via babel */

export default {
  getApiPath() {
    if(window && window.location) {
      let protocol = window.location.protocol;
      let port = window.location.port;
      return port && port.length ? `${protocol}//${document.getElementById('api-uri').content}:${port}` : `${protocol}//${document.getElementById('api-uri').content}`;
    }
  }
}