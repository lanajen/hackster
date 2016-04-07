import { Auth } from '../constants';

const initialState = {
  authorized: false
};

const MainReducer = (state = initialState, action) => {
  switch(action.type) {
    case Auth.AUTHORIZE:
      return { ...state, authorized: action.bool };

    default:
      return state;
  }
}



export default MainReducer