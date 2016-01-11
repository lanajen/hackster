import { History } from '../constants/ActionTypes';

export default function(state = [], action) {
  switch(action.type) {
    case History.addToHistory:
      return addToHistory([ ...state ], action.state);

    default:
      return state;
  };
}

function addToHistory(history, newState) {
  const maxStates = 10;

  if(history.length === maxStates) {
    history.shift();
    history.push(newState);
  } else {
    history.push(newState);
  }

  return history;
}