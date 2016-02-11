import { Logger } from '../constants/ActionTypes';

const initialState = {};

export default function(state = initialState, action) {
  switch(action.type) {
    case Logger.addLog:
      return {
        ...state,
        ...action.log
      };

    default:
      return state;
  }
}