import { fetchReviewThread, postDecision } from './utils/Requests';
import { postComment } from '../utils/ReactAPIUtils';

export const REQUEST_THREAD = 'REQUEST_THREAD';
export const RECEIVE_THREAD = 'RECEIVE_THREAD';
export const SUBMIT_DECISION = 'SUBMIT_DECISION';
export const SUBMIT_COMMENT = 'SUBMIT_COMMENT';
export const SET_COMMENT_SUBMITTED = 'SET_COMMENT_SUBMITTED';
export const SET_DECISION_SUBMITTED = 'SET_DECISION_SUBMITTED';

function requestThread() {
  return {
    type: REQUEST_THREAD
  };
}

function submitComment(comment) {
  return {
    type: SUBMIT_COMMENT,
    comment
  };
}

function setCommentSubmitted(comment) {
  return {
    type: SET_COMMENT_SUBMITTED,
    comment
  };
}

function submitDecision(decision) {
  return {
    type: SUBMIT_DECISION,
    decision
  };
}

function setDecisionSubmitted(decision) {
  return {
    type: SET_DECISION_SUBMITTED,
    decision
  };
}

function receiveThread(thread) {
  return {
    type: RECEIVE_THREAD,
    thread
  };
}

export function doSubmitComment(body, threadId, csrfToken) {
  return function(dispatch) {

    let comment = {
      comment: {
        raw_body: body
      },
      commentable: {
        id: threadId,
        type: 'review_thread'
      }
    };
    dispatch(submitComment(comment));

    let promise = postComment(comment, csrfToken);
    return promise
      .then(response =>
        dispatch(setCommentSubmitted(response))
      ).catch(function(err) { console.log('Request Error: ' + err); });
  };
}

export function doSubmitDecision(decision, projectId) {
  return function(dispatch) {
    dispatch(submitDecision(decision));

    let promise = postDecision(decision, projectId);
    return promise
      .then(response =>
        dispatch(setDecisionSubmitted(response.body.decision))
      ).catch(function(err) { console.log('Request Error: ' + err); });
  };
}

export function initialFetch(projectId) {
  return (dispatch, getState) => {
    return dispatch(fetchThreadFromServer(projectId));
  };
}

function fetchThreadFromServer(projectId) {
  return function (dispatch) {
    dispatch(requestThread());

    let promise = fetchReviewThread(projectId);
    return promise
      .then(response =>
        dispatch(receiveThread(response.body.thread))
      ).catch(function(err) { console.log('Response Error: ' + err); });
  };
}
