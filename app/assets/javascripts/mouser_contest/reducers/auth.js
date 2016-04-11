import { Auth } from '../constants';

const initialState = {
  isAuthorized: false
};

export default function auth(state = initialState, action) {
  switch(action.type) {
    case Auth.SET_AUTHORIZED:
      return { ...state, isAuthorized: action.bool };

    default:
      return state;
  }
}