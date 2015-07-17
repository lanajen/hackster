import { Test } from '../constants/ActionTypes';

const initialState = {
  text: 'HELLO'
};

export default function(state, action) {
  state = state || initialState;

  switch (action.type) {
  case Test.showTest:
    return state.text += ' world';
  default:
    return state;
  }
}