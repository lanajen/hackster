import request from 'superagent';
import postal from 'postal';
import _ from 'lodash';
import { getApiPath } from '../../utils/Utils';
import getApiToken from '../../services/oauth';

const channel = postal.channel('lists');

const listsStore = {

  isLoading: false,
  isPopulated: false,
  lists: [],

  addList(name) {
    if (!this.isLoading && this.isPopulated) {
      let promise = this.createList(name);
      this.isLoading = true;

      promise.then(function(response) {
        this.addToStore(response.body.list);
        this.isLoading = false;
      }.bind(this)).catch(function(err) { console.log('Request Error: ' + err); });
    }
  },

  createList(name) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .post(`${getApiPath()}/v2/lists`)
          .set('Authorization', `Bearer ${token}`)
          .send({ group: { full_name: name } })
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      }, true);
    });
  },

  fetchInitialData(projectId) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .get(`${getApiPath()}/v2/lists`)
          .set('Authorization', `Bearer ${token}`)
          .query({ project_id: projectId })
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      }, true);
    });
  },

  // public
  populateStore(projectId) {
    if (!this.isPopulated && !this.isLoading) {
      this.isLoading = true;
      let promise = this.fetchInitialData(projectId);

      promise.then(function(res) {
        let store = res.body.lists;
        this.lists = store;
        this.isPopulated = true;
        this.isLoading = false;
        // this.isLoading = false;
        channel.publish('initial.store', store);
      }.bind(this)).catch(function(err) {
        console.log('Fetch Error: ' + err);
      });

    }
  },

  addToStore(list) {
    let store = this.lists;
    store.push(list);
    this.lists = store;

    channel.publish('store.changed', store);
  },

  getStore() {
    return this.lists;
  },

  setStore(newStore) {
    this.lists = newStore;
  }

};

export default listsStore;