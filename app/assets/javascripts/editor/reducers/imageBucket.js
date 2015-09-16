import { ImageBucket } from '../constants/ActionTypes';

const initialState = {
  show: false
};

export default function(state, action) {
  state = state || initialState;
  let newState;

  switch (action.type) {

  case ImageBucket.show:
    return {
      ...state,
      show: true
    };

  case ImageBucket.hide:
    return {
      ...state,
      show: false
    };

  default:
    return state;
  }
}