import { Comments } from '../constants/ActionTypes';

export function hello() {
  return {
    type: Comments.hello,
    text: 'hello'
  };
}