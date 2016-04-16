/* Utilities for Mouser Competition */

export default {

  determineHost() {
    if (window && window.location) {
      return 'http://mousercontest.localhost.local:5000'
    }
  }

}