import request from 'superagent';
import { fetchFollowing } from '../../utils/ReactAPIUtils';
import postal from 'postal';
import _ from 'lodash';

const channel = postal.channel('followers');

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
        channel.publish('initial.store', store);
      }.bind(this)).catch(function(err) {
        console.log('Fetch Error: ' + err)
      });

    }
  },

  fetchInitialData(csrfToken) {
    return fetchFollowing(csrfToken);
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

    channel.publish('store.changed', store);
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

    channel.publish('store.changed', store);
    this.followersStore = store;
  }

};

export default followersStore;