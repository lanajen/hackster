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
        nextPage: x,
        currentPage: x
      }
    },
    partsById: {
      id: {
        isFollowing: false,
        isLoading: false,
        ...
      }
    },
    followedPartIds: [id, id]
  }
*/

import { combineReducers } from 'redux';
import {
  SELECT_PARTS, REQUEST_PARTS, RECEIVE_PARTS,
  FOLLOW_PART, UNFOLLOW_PART, UPDATING_FOLLOW,
  REQUEST_FOLLOWING, RECEIVE_FOLLOWING, SortFilters, generateKey
} from './actions';

function selectedQueryKey(state = `:${SortFilters.MOST_FOLLOWED}:1`, action) {
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
      nextPage: action.nextPage,
      currentPage: action.currentPage
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
  let part;
  switch (action.type) {
  case RECEIVE_PARTS:
  case REQUEST_PARTS:
    return Object.assign({}, state, organizePartsById(action.parts));
  case UPDATING_FOLLOW:
    part = action.parts[action.partId];
    part.isLoading = true;
    action.parts[action.partId] = part;
    console.log('action.parts', action.parts);
    return Object.assign({}, state, action.parts);
  case FOLLOW_PART:
    part = action.parts[action.partId];
    part.isLoading = false;
    part.isFollowing = true;
    action.parts[action.partId] = part;
    return Object.assign({}, state, action.parts);
  case UNFOLLOW_PART:
    part = action.parts[action.partId];
    part.isLoading = false;
    part.isFollowing = false;
    action.parts[action.partId] = part;
    return Object.assign({}, state, action.parts);
  default:
    return state;
  }
}

function followedPartIds(state = [], action) {
  let newState = Object.assign([], state);
  switch (action.type) {
  case RECEIVE_FOLLOWING:
    return Object.assign([], action.following);
  // case REQUEST_FOLLOWING:
  case FOLLOW_PART:
    newState.push(action.partId);
    return newState;
  case UNFOLLOW_PART:
    let i = newState.indexOf(action.partId);
    newState.splice(i, 1);
    return newState;
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

// function updatePart(state = {}, action) {
//   console.log('ACTION', action);
//   // if (!part) return state;
//   let part;
//   if (action.parts) part = action.parts[action.partId];

//   switch (action.type) {
//   case UPDATING_FOLLOW:
//     part.isLoading = true;
//     action.parts[action.partId] = part;
//     console.log('action.parts', action.parts);
//     // return Object.assign({}, state, {
//     //   items: action.parts.map((part, i) => part.id)
//     // });
//   case FOLLOW_PART:
//     part.isLoading = false;
//     part.isFollowing = true;
//     action.parts[action.partId] = part;
//     return Object.assign({}, state, action.parts);
//   case UNFOLLOW_PART:
//     part.isLoading = false;
//     part.isFollowing = false;
//     action.parts[action.partId] = part;
//     return Object.assign({}, state, action.parts);
//   default:
//     return state;
//   }
// }

const rootReducer = combineReducers({
  partsByQueryKey,
  selectedQueryKey,
  partsById,
  followedPartIds
});

export default rootReducer;