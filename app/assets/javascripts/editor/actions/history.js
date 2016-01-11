import { History } from '../constants/ActionTypes';

export function addToHistory(state) {
  return {
    type: History.addToHistory,
    state: state
  };
}