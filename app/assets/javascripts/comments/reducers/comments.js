import { Comments } from '../constants/ActionTypes';

const initialState = {
  comments: []
};

export default function(state = initialState, action) {
  switch(action.type) {

    case Comments.setInitialComments:
      return {
        ...state,
        comments: action.comments
      };

    default:
      return state;
  }
}