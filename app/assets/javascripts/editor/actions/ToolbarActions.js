import ActionTypes from '../constants/ActionTypes';

export function showTest(text) {
  return {
    type: ActionTypes.Test.showTest,
    text: text || 'Nothing sent'
  };
}