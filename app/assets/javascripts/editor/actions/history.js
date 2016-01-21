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
    let lastState = history.undoStore[history.undoStore.length - 1];


    if(!history.undoStore.length || ( lastState.dom && !_.isEqual(lastState.dom, state.dom))) {
      lastState ? console.log('DIFF', lastState.dom, state.dom) : console.log('IN ACTION ', !history.undoStore.length);

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

export function undoHistoryState() {
  return {
    type: History.undoHistoryState
  };
}

export function getPreviousHistoryState() {
  return function(dispatch, getState) {
    let undoStore = getState().history.undoStore;
    // The last index is always the current shown state. We want a clone of the true previous state.
    let previousStateIndex = undoStore.length <= 1 ? (undoStore.length - 1) : (undoStore.length - 2);

    undoStore.length > 1 ? dispatch(undoHistoryState()) : true;
    return _.cloneDeep( undoStore[previousStateIndex] );
  }
}

export function redoHistoryState() {
  return {
    type: History.redoHistoryState
  };
}

export function getNextHistoryState() {
  return function(dispatch, getState) {
    let redoStore = getState().history.redoStore;
    let nextStateIndex = redoStore.length - 1;

    redoStore.length >= 1 ? dispatch(redoHistoryState()) : true;
    return _.cloneDeep( redoStore[nextStateIndex] );
  };
}