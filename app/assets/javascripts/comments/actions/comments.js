import { Comments } from '../constants/ActionTypes';
import Requests from '../utils/Requests';
import { fetchCurrentUser } from '../../utils/ReactAPIUtils';

export function getCurrentUser() {
  return function(dispatch) {
    return fetchCurrentUser()
      .then(user => {
        dispatch(setCurrentUser(user))
      })
      .catch(err => {
        console.log('Fetch error: ', err);
      });
  }
}

export function setCurrentUser(user) {
  return {
    type: Comments.setCurrentUser,
    user: user
  }
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

export function setInitialComments(comments) {
  return {
    type: Comments.setInitialComments,
    comments: comments
  };
}

export function addComment(comment, isReply) {
  return {
    type: Comments.addComment,
    comment: comment,
    isReply: isReply
  };
}

export function postComment(comment, isReply) {
  return function(dispatch) {
    return Requests.postComment(comment)
      .then(response => {
        dispatch(addComment(response, isReply));
      })
      .catch(err => {
        console.log('POST ERROR', err);
      });
  }
}

export function removeComment(comment) {
  return {
    type: Comments.removeComment,
    comment: comment
  };
}

export function deleteComment(data) {
  return function(dispatch) {
    return Requests.deleteComment(data.id, data.csrfToken)
      .then(response => {
        dispatch(removeComment(response));
      })
      .catch(err => {
        console.log('DEL ERROR', err);
      });
  }
}

export function toggleFormData(isLoading, error) {
  return {
    type: Comments.toggleFormData,
    isLoading: isLoading,
    error: error
  };
}

export function toggleScrollTo(scroll, element) {
  return {
    type: Comments.toggleScrollTo,
    scroll: scroll,
    element: element
  };
}

export function triggerReplyBox(show, id) {
  return {
    type: Comments.triggerReplyBox,
    show: show,
    id: id
  };
}