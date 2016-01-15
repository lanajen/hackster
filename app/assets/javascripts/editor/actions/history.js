import { History } from '../constants/ActionTypes';
import * as EditorActions from './editor';
import _ from 'lodash';

export function addToHistory(state) {
  return {
    type: History.addToHistory,
    state: state
  };
}

export function updateHistory(state) {
  return function(dispatch, getState) {
    let history = getState().history;
    let lastState = history.store[history.currentLiveIndex];

    console.log("HEY", lastState, state);

    if(lastState !== undefined && _.isEqual(lastState.dom, state.dom)) {
      console.log('YUP');
      return;
    }

    if(!_.isEqual(lastState, state)) {
      dispatch(addToHistory(state));
    }
  };
}

export function updateCurrentLiveIndex(index) {
  return {
    type: History.updateCurrentLiveIndex,
    index: index
  };
}

export function getPreviousHistoryState() {
  return function(dispatch, getState) {
    // debugger;
    let history = getState().history;
    let currentLiveIndex = history.currentLiveIndex === 0 ? 0 : history.currentLiveIndex-1;

    console.log('PREV', history.store[currentLiveIndex], currentLiveIndex, history.store);
    dispatch(updateCurrentLiveIndex(currentLiveIndex));
    return _.cloneDeep( history.store[currentLiveIndex] );
  }
}

export function getNextHistoryState() {
  return function(dispatch, getState) {
    let history = getState().history;
    let currentLiveIndex = history.currentLiveIndex+1 === history.store.length ? history.currentLiveIndex : history.currentLiveIndex+1;

    console.log('NEXT', history.store[currentLiveIndex], currentLiveIndex);
    dispatch(updateCurrentLiveIndex(currentLiveIndex));
    return _.cloneDeep( history.store[currentLiveIndex] );
  };
}