import request from 'superagent';
import postal from 'postal';
import _ from 'lodash';

const followersStore = {

  followersStore: {},

  isFetching: false,

  populateStore(csrfToken) {
    if(!this.followersStore.length && this.isFetching === false) {
      this.isFetching = true;
      let promise = this.fetchInitialData(csrfToken);
      promise.then(function(res) {
        let store = res.body.following;
        this.followersStore = store;
        
        postal.publish({
          channel: 'followers',
          topic: 'initial.store',
          data: store
        });
      }.bind(this)).catch(function(err) {console.log('Fetch Error: ' + err)});
    }
  },

  fetchInitialData(csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .get('/api/v1/followers')
        .set('X-CSRF-Token', csrfToken)
        .end(function(err, res) {
          err ? reject(err) : resolve(res); 
        });
    });
  },

  isStorePopulated() {
    return this.followersStore.length > 0;
  },

  setStore(newStore) {
    this.followersStore = newStore;
  },

  getStore() {
    return this.followersStore;
  },

  addToStore(id, type) {
    let store = this.followersStore;
    store[type].push(id);
    this.followersStore = store;

    postal.publish({
      channel: 'followers',
      topic: 'add',
      data: store
    });
  }, 

  removeFromStore(id, type) {
    let store = this.followersStore;
    let bucket;
    for(let key in store) {
      if(key === type) {
        bucket = _.filter(store[key], function(item) {
          return item !== id;
        });
        store[key] = bucket;
      }
    }

    console.log('newStore', store);
    this.followersStore = store;
  }

};

export default followersStore;