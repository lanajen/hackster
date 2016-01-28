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

import { Wizard } from './constants/ActionTypes';

const initialState = {
  university: null,
  course: null,
  promotion: null
};

export default function store(state = initialState, action) {
  switch (action.type) {

    case Wizard.setStore:
      return {
        ...state,
        [action.storeName]: action.store
      };

    case Wizard.changeSelection:
      return changeSelection({...state}, action.storeName);

    default:
      return state;
  }
}

function changeSelection(state, storeName) {
  if(storeName === 'university') {
    state = {
      university: null,
      course: null,
      promotion: null
    };
  } else if(storeName === 'course') {
    state = {
      university: state.university,
      course: null,
      promotion: null
    };
  } else {
    state[storeName] = null;
  }
  return state;
}