/* Utilities for Mouser Competition */

export default {

  determineHost() {
    if (window && window.location) {
      const api_path = window.location.hostname.split('.')[0] === 'mousercontest'
        ? 'http://mousercontest.localhost.local:5000/api/import?user_id='
        : 'http://mousercontest.hackster.io/api/import?user_id=';

      return api_path;
    }
  }

}