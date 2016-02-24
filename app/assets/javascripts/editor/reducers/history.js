import { History } from '../constants/ActionTypes';

const initialState = {
  undoStore: [],
  redoStore: []
};

export default function(state = initialState, action) {
  let stores;
  switch(action.type) {
    case History.addToHistory:
      stores = addToHistory([ ...state.undoStore ], [], action.state);
      return {
        ...state,
        ...stores
      };

    case History.undoHistoryState:
      stores = undoHistoryState([ ...state.undoStore ], [ ...state.redoStore ]);
      return {
        ...state,
        ...stores
      };

    case History.redoHistoryState:
      stores = redoHistoryState([ ...state.undoStore ], [ ...state.redoStore ]);
      return {
        ...state,
        ...stores
      };

    case History.replaceLastInUndoStore:
      return {
        ...state,
        undoStore: replaceLastInUndoStore([ ...state.undoStore ], action.state)
      };

    default:
      return state;
  };
}

function addToHistory(undoStore, redoStore, newState) {
  const maxStates = 50;
  if(undoStore.length === maxStates) {
    undoStore.shift();
    undoStore.push(newState);
  } else {
    undoStore.push(newState);
  }

  return { undoStore, redoStore };
}

function undoHistoryState(undoStore, redoStore) {
  redoStore.push(undoStore.pop());
  return { undoStore, redoStore };
}

function redoHistoryState(undoStore, redoStore) {
  undoStore.push(redoStore.pop());
  return { undoStore, redoStore };
}

function replaceLastInUndoStore(undoStore, newState) {
  undoStore.pop();
  undoStore.push(newState);
  return undoStore;
}