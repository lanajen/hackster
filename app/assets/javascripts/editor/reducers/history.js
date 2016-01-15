import { History } from '../constants/ActionTypes';

const initialState = {
  store: [],
  currentLiveIndex: 0
};

export default function(state = initialState, action) {
  switch(action.type) {
    case History.addToHistory:
      let newStore = addToHistory([ ...state.store ], action.state, state.currentLiveIndex);
      console.log('UPDATE HISTORY!', newStore, action.state, newStore.length-1);
      return {
        ...state,
        store: newStore,
        currentLiveIndex: newStore.length-1
      };

    case History.updateCurrentLiveIndex:
      return {
        ...state,
        currentLiveIndex: action.index
      };

    default:
      return state;
  };
}

function addToHistory(history, newState, currentLiveIndex) {
  const maxStates = 10;

  if(currentLiveIndex+1 < history.length) {
    console.log('SLICING', history, currentLiveIndex+1, history.length);
    history = history.slice(0, currentLiveIndex+1);
  }

  if(history.length === maxStates) {
    history.shift();
    history.push(newState);
  } else {
    history.push(newState);
  }

  return history;
}