/** Global Utils | Exposed in components.js via babel */

export default {
  getApiPath() {
    if(window && window.location) {
      let hostname = window.location.host;
      let protocol = window.location.protocol;
      return hostname.split('.').indexOf('www') !== -1 || hostname.split('.').indexOf('arduino') !== -1
        ? `${protocol}//${hostname.split('.').map(item => {
          const subdomains = ['www', 'arduino'];
          return subdomains.indexOf(item) >= 0 ? 'api' : item;
        }).join('.')}`
        : `${protocol}//api.${hostname}`;
    }
  }
}