/*
  {
    university: {
      id
      name
      logo_url
      city
      country
    },
    course: {},
    promotion: {},
    members: {
      professors: [],
      tas: [],
      students: []
    }
  }
*/

import { combineReducers } from 'redux';
import {
  SEARCH_UNIVERSITY, RECEIVE_UNIVERSITIES, SELECT_UNIVERSITY
} from './actions';

function store(state = {
  university: null,
  course: null,
  promotion: null
}, action) {
  switch (action.type) {
    case SEARCH_UNIVERSITY:
      return Object.assign({}, state, {});

    default:
      return state;
  }
}

const rootReducer = combineReducers({
  store
});

export default rootReducer;