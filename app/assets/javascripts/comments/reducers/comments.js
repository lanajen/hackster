import { Comments } from '../constants/ActionTypes';

const initialState = {};

export default function(state = initialState, action) {
  switch(action.type) {

    case Comments.hello:
      return {
        ...state
      };

    default:
      return state;
  }
}