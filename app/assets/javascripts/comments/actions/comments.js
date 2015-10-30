import { Comments } from '../constants/ActionTypes';
import Requests from '../utils/Requests';

export function setInitialComments(comments) {
  return {
    type: Comments.setInitialComments,
    comments: comments
  };
}

export function getInitialComments(commentable, csrfToken) {
  return function(dispatch) {
    return Requests.getComments(commentable, csrfToken)
      .then(comments => {
        dispatch(setInitialComments(comments));
      })
      .catch(err => {
        console.log('Fetch Error: ', err);
      });
  }
}

export function postComment(comment) {
  return function(dispatch) {
    return Requests.postComment(comment)
      .then(response => {
        console.log('YAY', response);
      }).catch(err => {
        console.log('POST ERROR', err);
      });
  }
}