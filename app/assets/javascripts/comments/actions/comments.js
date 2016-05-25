import { Comments } from '../constants/ActionTypes';
import Requests from '../utils/Requests';
import SharedRequests from '../../utils/ReactAPIUtils';
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

export function getInitialComments(commentable, cacheVersion) {
  return function(dispatch) {
    return Requests.getComments(commentable, cacheVersion)
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
    return SharedRequests.postComment(comment)
      .then(response => {
        dispatch(addComment(response, isReply));
      })
      .catch(err => {
        console.log('POST ERROR', err);
      });
  }
}

export function toggleLikes(commentId, parentId, bool) {
  return {
    type: Comments.toggleLikes,
    commentId: commentId,
    parentId: parentId,
    bool: bool
  };
}

export function deleteLike(commentId, parentId) {
  return function(dispatch) {
    return Requests.deleteLike(commentId)
      .then(response => {
        dispatch(toggleLikes(commentId, parentId, response));
      })
      .catch(err => {
        console.log('DEL ERROR', err);
      });
  }
}

export function postLike(commentId, parentId) {
  return function(dispatch) {
    return Requests.postLike(commentId)
      .then(response => {
        dispatch(toggleLikes(commentId, parentId, response));
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

export function deleteComment(id) {
  return function(dispatch) {
    return Requests.deleteComment(id)
      .then(response => {
        dispatch(removeComment(response));
      })
      .catch(err => {
        console.log('DEL ERROR', err);
      });
  }
}

export function removeIdFromDeleteList(id) {
  return {
    type: Comments.removeIdFromDeleteList,
    id: id
  };
}

export function toggleCommentUpdated() {
  return {
    type: Comments.toggleCommentUpdated
  };
}

export function toggleFormData(isLoading, error, id) {
  return {
    type: Comments.toggleFormData,
    isLoading: isLoading,
    error: error,
    id: id
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

export function updateComment(comment) {
  return {
    type: Comments.updateComment,
    comment: comment
  };
}

export function patchComment(comment) {
  return function(dispatch) {
    return Requests.updateComment(comment)
      .then(response => {
        dispatch(updateComment(response));
      })
      .catch(err => {
        console.log('UPDATE ERROR: ', err);
      });
  }
}