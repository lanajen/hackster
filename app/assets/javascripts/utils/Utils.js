/** Global Utils | Exposed in components.js via babel */

export default {
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

  getCSRFToken() {
    let metaList = document.getElementsByTagName('meta');
    let csrfToken;

    [].slice.call(metaList).forEach(m => {
      if(m.name === 'csrf-token' && m.content) { csrfToken = m.content }
    });

    return csrfToken;
  }
}