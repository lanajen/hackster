import { History } from '../constants/ActionTypes';
import _ from 'lodash';

export function addToHistory(state) {
  return {
    type: History.addToHistory,
    state: state
  };
}

export function updateHistory(state) {
  return function(dispatch, getState) {
    let currentState = getState().history;
    let lastState = currentState[currentState.length-1];

    if(!_.isEqual(lastState, state)) {
      dispatch(addToHistory(state));
    }
  };
}