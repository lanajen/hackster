import request from 'superagent';
import { Wizard } from './constants/ActionTypes';
import { postForm, getOptions } from './requests';

export function getOptionsHandler(query) {
  return function(dispatch) {
    return getOptions(query)
      .then(response => {
        return Promise.resolve(response);
      })
      .catch(err => {
        console.error('GET Options ERROR ', err);
      });
  };
}

function setStore(storeName, store) {
  return {
    type: Wizard.setStore,
    storeName: storeName,
    store: store
  };
}

export function postFormHandler(form, endpoint, csrfToken, imageData) {
  return function(dispatch) {
    return postForm(form, endpoint, csrfToken)
      .then(response => {
        let store = imageData !== null ? { ...response, imageData } : response;
        dispatch(setStore(form.type.toLowerCase(), store));
      })
      .catch(err => {
        console.log('POST Form ERROR: ', err);
      });
  };
}

export function setSelectionValue(store, storeName) {
  return function(dispatch) {
    dispatch(setStore(storeName, store));
  };
}

export function changeSelection(storeName) {
  return {
    type: Wizard.changeSelection,
    storeName: storeName
  };
}

