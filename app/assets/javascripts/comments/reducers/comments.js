import { Comments } from '../constants/ActionTypes';

const initialState = {
  comments: [],
  commentUpdated: { id: null },
  fetchedInitialComments: false,
  formData: { isLoading: false, error: null, id: null },
  replyBox: { show: false, id: null },
  rootCommentsToDelete: [],
  scrollTo: { scroll: false, element: null },
  user: {},
};

export default function(state = initialState, action) {
  let newComments, scrollTo;

  switch(action.type) {

    case Comments.setCurrentUser:
      return {
        ...state,
        user: action.user
      };

    case Comments.setInitialComments:
      return {
        ...state,
        comments: action.comments,
        fetchedInitialComments: true
      };

    case Comments.addComment:
      newComments = addComment(state.comments, action.comment);
      scrollTo = action.isReply === false ? { scroll: true, element: action.comment } : state.scrollTo;
      return {
        ...state,
        comments: newComments,
        scrollTo: scrollTo,
        replyBox: { show: false, id: null },
        formData: { isLoading: false, errors: null, id: null }
      };

    case Comments.updateComment:
      return {
        ...state,
        comments: updateComment(state.comments, action.comment),
        formData: { isLoading: false, errors: null, id: null },
        commentUpdated: { id: action.comment.id }
      };

    case Comments.removeComment:
      newComments = removeComment(state.comments, action.comment);
      let rootCommentsToDelete = createListOfIdsToDelete(newComments);
      return {
        ...state,
        comments: newComments,
        rootCommentsToDelete: rootCommentsToDelete
      };

    case Comments.removeIdFromDeleteList:
      return {
        ...state,
        rootCommentsToDelete: state.rootCommentsToDelete.filter(id => id !== action.id)
      };

    case Comments.toggleCommentUpdated:
      return {
        ...state,
        commentUpdated: { id: null }
      };

    case Comments.toggleFormData:
      return {
        ...state,
        formData: { isLoading: action.isLoading, error: action.error, id: action.id }
      };

    case Comments.toggleLikes:
      return {
        ...state,
        comments: toggleLikes(state.comments, action.commentId, action.parentId, state.user.id, action.bool)
      };

    case Comments.toggleScrollTo:
      return {
        ...state,
        scrollTo: { scroll: action.scroll, element: action.element }
      };

    case Comments.triggerReplyBox:
      return {
        ...state,
        replyBox: { show: action.show, id: action.id }
      };

    default:
      return state;
  }
}

function addComment(comments, comment) {
  if(!comment.parent_id) {
    comments.push({ root: comment, children: [] });
  } else {
    comments = comments.map(cmt => {
      if(cmt.root.id === comment.parent_id) {
        cmt.children.push(comment);
      }
      return cmt;
    });
  }
  return comments;
}

function removeComment(comments, comment) {
  return comments.reduce((acc, curr) => {
    if(curr.root.id === comment.parent_id) {
      curr.children = curr.children.filter(child => {
        return child.id !== comment.id;
      });
      acc.push(curr);
    } else if(curr.root.id === comment.id && curr.children.length > 0) {
      curr.root = { ...curr.root, deleted: true };
      acc.push(curr);
    } else if(curr.root.id !== comment.id) {
      acc.push(curr);
    }
    return acc;
  }, []);
}

function createListOfIdsToDelete(comments) {
  return comments.reduce((acc, curr) => {
    if(curr.root.deleted && curr.children.length < 1) {
      acc.push(curr.root.id);
    }
    return acc;
  }, []);
}

function toggleLikes(comments, commentId, parentId, userId, bool) {
  return comments.map(comment => {
    if(parentId === null && comment.root.id === commentId) {
      comment.root.likingUsers = _addToOrRemoveFromArray(comment.root.likingUsers, bool, userId);
    } else {
      comment.children = comment.children.map(child => {
        if(child.id === commentId) {
          child.likingUsers = _addToOrRemoveFromArray(child.likingUsers, bool, userId);
        }
        return child;
      });
    }
    return comment;
  });
}

function _addToOrRemoveFromArray(array, bool, item) {
  console.log('array', array, 'bool', bool, 'item', item);
  if(bool) {
    array.push(item);
  } else {
    array = array.filter((x) => { return item !== x; });
  }
  console.log('array', array);
  return array;
}

function updateComment(comments, newComment) {
  return comments.map(comment => {
    if(newComment.parent_id) {
      comment.children = comment.children.map(child => {
        child = child.id === newComment.id ? newComment : child;
        return child;
      });
    } else {
      comment.root = comment.root.id === newComment.id ? newComment : comment.root;
    }
    return comment;
  });
}