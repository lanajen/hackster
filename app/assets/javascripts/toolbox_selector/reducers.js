/*
  {
    selectedQueryKey: ':MOST_FOLLOWED:1'
    partsByQueryKey: {
      ':MOST_FOLLOWED:1' : {
        items: [id, id],
        isFetching: false,
        query: query,
        sort: sort,
        totalResults: x,
        nextPage: x
      }
    },
    partsById: {
      id: {}
    }
  }
*/

import { combineReducers } from 'redux';
import {
  SELECT_PARTS, REQUEST_PARTS, RECEIVE_PARTS,
  FOLLOW_PART, UNFOLLOW_PART, SortFilters, generateKey
} from './actions';

function selectedQueryKey(state = ':MOST_FOLLOWED:1', action) {
  switch (action.type) {
  case SELECT_PARTS:
    return generateKey(action.request);
  default:
    return state;
  }
}

function parts(state = {
  isFetching: false,
  items: [],
  request: { query: '', sort: SortFilters.MOST_FOLLOWED, page: 1 }
}, action) {
  console.log('parts()', 'ACTION', action);
  switch (action.type) {
  case REQUEST_PARTS:
    return Object.assign({}, state, {
      isFetching: true,
      request: action.request
    });
  case RECEIVE_PARTS:
    return Object.assign({}, state, {
      isFetching: false,
      items: action.parts.map((part, i) => part.id),
      nextPage: action.nextPage
    });
  default:
    return state;
  }
}

function partsByQueryKey(state = {}, action) {
  switch (action.type) {
  case RECEIVE_PARTS:
  case REQUEST_PARTS:
    let key = generateKey(action.request);
    let partsHash = parts(state[key], action);
    // console.log('partsByQueryKey', 'REQUEST_PARTS', 'action', action);
    // console.log('partsByQueryKey', 'REQUEST_PARTS', 'key', key);
    // console.log('partsByQueryKey', 'REQUEST_PARTS', 'parts', partsHash);
    return Object.assign({}, state, {
      [key]: partsHash
    });
  default:
    return state;
  }
}

function partsById(state = {}, action) {
  switch (action.type) {
  case RECEIVE_PARTS:
  case REQUEST_PARTS:
    return Object.assign({}, state, organizePartsById(action.parts));
  default:
    return state;
  }
}

function organizePartsById(parts = []) {
  let hash = {};
  for (let i = 0; i < parts.length; ++i) {
    let part = parts[i];
    hash[part.id] = part;
  }
  return hash;
}

const rootReducer = combineReducers({
  partsByQueryKey,
  selectedQueryKey,
  partsById
});

export default rootReducer;