import { Comments } from '../constants/ActionTypes';

const initialState = {
  comments: [],
  formData: { isLoading: false, error: null },
  replyBox: { show: false, id: null },
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
        comments: action.comments
      };

    case Comments.addComment:
      newComments = addComment(state.comments, action.comment);
      scrollTo = action.isReply === false ? { scroll: true, element: action.comment } : state.scrollTo;
      return {
        ...state,
        comments: newComments,
        scrollTo: scrollTo,
        replyBox: { show: false, id: null },
        formData: { isLoading: false, errors: null }
      };

    case Comments.removeComment:
      newComments = removeComment(state.comments, action.comment);
      return {
        ...state,
        comments: newComments
      };

    case Comments.toggleFormData:
      return {
        ...state,
        formData: { isLoading: action.isLoading, error: action.error }
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
  return comments.reduce((prev, curr) => {
    if(curr.root.id === comment.parent_id) {
      curr.children = curr.children.filter(child => {
        return child.id !== comment.id;
      });
      prev.push(curr);
    } else if(curr.root.id !== comment.id) {
      prev.push(curr);
    }
    return prev;
  }, []);
}