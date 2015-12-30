/*
  {
    decisions: [
      {
        user: {},
        fields: {},
        decision: decision,
        timestamp: timestamp
      }
    ],
    comments: [
      {
        id: id,
        body: body,
        user: { id: id, name: name, avatar: url, slug: slug },
        timestamp: timestamp
      }
    ],
    update: [
      {
        user: {},
        action: action,
        meta: {}
      }
    ]
  }
*/

import { combineReducers } from 'redux';
import {
  REQUEST_THREAD, RECEIVE_THREAD, SUBMIT_DECISION
} from './actions';

// function selectedQueryKey(state = `:${SortFilters.MOST_FOLLOWED}:1`, action) {
//   switch (action.type) {
//   case SELECT_PARTS:
//     return generateKey(action.request);
//   default:
//     return state;
//   }
// }

// function parts(state = {
//   isFetching: false,
//   items: [],
//   request: { query: '', sort: SortFilters.MOST_FOLLOWED, page: 1 }
// }, action) {
//   switch (action.type) {
//   case REQUEST_PARTS:
//     return Object.assign({}, state, {
//       isFetching: true,
//       request: action.request
//     });
//   case RECEIVE_PARTS:
//     return Object.assign({}, state, {
//       isFetching: false,
//       items: action.parts.map((part, i) => part.id),
//       nextPage: action.nextPage,
//       currentPage: action.currentPage
//     });
//   default:
//     return state;
//   }
// }

// function partsByQueryKey(state = {}, action) {
//   switch (action.type) {
//   case RECEIVE_PARTS:
//   case REQUEST_PARTS:
//     let key = generateKey(action.request);
//     let partsHash = parts(state[key], action);
//     return Object.assign({}, state, {
//       [key]: partsHash
//     });
//   default:
//     return state;
//   }
// }

// function partsById(state = {}, action) {
//   let part;
//   switch (action.type) {
//   case RECEIVE_PARTS:
//   case REQUEST_PARTS:
//     return Object.assign({}, state, organizePartsById(action.parts));
//   case UPDATING_FOLLOW:
//     part = action.parts[action.partId];
//     part.isLoading = true;
//     action.parts[action.partId] = part;
//     return Object.assign({}, state, action.parts);
//   case FOLLOW_PART:
//     part = action.parts[action.partId];
//     part.isLoading = false;
//     part.isFollowing = true;
//     action.parts[action.partId] = part;
//     return Object.assign({}, state, action.parts);
//   case UNFOLLOW_PART:
//     part = action.parts[action.partId];
//     part.isLoading = false;
//     part.isFollowing = false;
//     action.parts[action.partId] = part;
//     return Object.assign({}, state, action.parts);
//   default:
//     return state;
//   }
// }

// function followedPartIds(state = [], action) {
//   let newState = Object.assign([], state);
//   switch (action.type) {
//   case RECEIVE_FOLLOWING:
//     return Object.assign([], action.following);
//   case FOLLOW_PART:
//     newState.push(action.partId);
//     return newState;
//   case UNFOLLOW_PART:
//     let i = newState.indexOf(action.partId);
//     newState.splice(i, 1);
//     return newState;
//   default:
//     return state;
//   }
// }

// function organizePartsById(parts = []) {
//   let hash = {};
//   for (let i = 0; i < parts.length; ++i) {
//     let part = parts[i];
//     hash[part.id] = part;
//   }
//   return hash;
// }

function currentThread(state = {
  decisions: [],
  comments: [],
  updates: []
}, action) {
  switch (action.type) {
    case REQUEST_THREAD:
    case RECEIVE_THREAD:
      return Object.assign({}, action.thread);
    default:
      return state;
  }
}

function decisions(state = [], action) {
  switch (action.type) {
    case SUBMIT_DECISION:
      let newState = Object.assign([], state);
      newState.push(action.decision);
      return newState;
    default:
      return state;
  }
}

const rootReducer = combineReducers({
  currentThread,
  decisions
//   partsByQueryKey,
//   selectedQueryKey,
//   partsById,
//   followedPartIds
});

export default rootReducer;