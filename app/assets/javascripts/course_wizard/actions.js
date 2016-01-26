import { fetchReviewThread, postDecision, postComment } from '../utils/ReactAPIUtils';

export const SEARCH_UNIVERSITY = 'SEARCH_UNIVERSITY';
export const RECEIVE_UNIVERSITIES = 'RECEIVE_UNIVERSITIES';
export const SELECT_UNIVERSITY = 'SELECT_UNIVERSITY';
export const SUBMIT_UNIVERSITY = 'SUBMIT_UNIVERSITY';
export const RECEIVE_UNIVERSITY = 'RECEIVE_UNIVERSITY';

function searchUniversity(query) {
  return {
    type: SEARCH_UNIVERSITY,
    query
  };
}

function receiveUniversities(results) {
  return {
    type: RECEIVE_UNIVERSITIES,
    results
  };
}

function selectUniversity(university) {
  return {
    type: SELECT_UNIVERSITY,
    university
  };
}

function submitUniversity(university) {
  return {
    type: SUBMIT_UNIVERSITY,
    university
  };
}

function receiveUniversity(university) {
  return {
    type: RECEIVE_UNIVERSITY,
    university
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
