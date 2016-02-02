import request from 'superagent';
import { addToFollowing, removeFromFollowing, fetchFollowing } from '../utils/ReactAPIUtils';

export const SELECT_PARTS = 'SELECT_PARTS';
export const REQUEST_PARTS = 'REQUEST_PARTS';
export const RECEIVE_PARTS = 'RECEIVE_PARTS';
export const UPDATING_FOLLOW = 'UPDATING_FOLLOW';
export const FOLLOW_PART = 'FOLLOW_PART';
export const UNFOLLOW_PART = 'UNFOLLOW_PART';
export const REQUEST_FOLLOWING = 'REQUEST_FOLLOWING';
export const RECEIVE_FOLLOWING = 'RECEIVE_FOLLOWING';

export const SortFilters = {
  ALPHABETICAL: 'alpha',
  MOST_FOLLOWED: 'owned',
  MOST_USED: 'used'
};

export function selectParts(request) {
  return {
    type: SELECT_PARTS,
    request
  };
}

function requestParts(request) {
  return {
    type: REQUEST_PARTS,
    request
  };
}

function receiveParts(request, response) {
  return {
    type: RECEIVE_PARTS,
    parts: response.parts,
    nextPage: response.next_page,
    currentPage: response.page,
    request
  };
}

function requestFollowing() {
  return {
    type: REQUEST_FOLLOWING
  };
}

function receiveFollowing(response) {
  return {
    type: RECEIVE_FOLLOWING,
    following: response.following.part || []
  };
}

export function fetchParts(request) {
  return function (dispatch) {
    dispatch(requestParts(request));

    let promise = fetchPartsFromServer(request);
    return promise
      .then(response =>
        dispatch(receiveParts(request, response.body))
      ).catch(function(err) { console.log('Request Error: ' + err); });
  };
}

function fetchPartsFromServer(req) {
  return new Promise((resolve, reject) => {
    request
      .get('/api/v1/parts')
      .query({ q: req.query, sort: req.filter, page: req.page, image_size: 'medium', approved: true })
      .withCredentials()
      .end(function(err, res) {
        err ? reject(err) : resolve(res);
      });
  });
}

function doFollowPart(partId, parts) {
  return function (dispatch) {
    dispatch(updatingFollow(partId, parts));

    let promise = addToFollowing(partId, 'Part', 'toolbox_selector');
    return promise
      .then(response =>
        dispatch(followPart(partId, parts))
      ).catch(function(err) { console.log('Request Error: ' + err); });
  };
}

function doUnfollowPart(partId, parts) {
  return function (dispatch) {
    dispatch(updatingFollow(partId, parts));

    let promise = removeFromFollowing(partId, 'Part', 'toolbox_selector');
    return promise
      .then(response =>
        dispatch(unfollowPart(partId, parts))
      ).catch(function(err) { console.log('Request Error: ' + err); });
  };
}

function shouldFetchParts(state, queryKey) {
  const parts = state.partsByQueryKey[queryKey];
  if (!parts) {
    return true;
  } else {
    return false;
  }
}

export function fetchPartsIfNeeded(queryKey) {
  return (dispatch, getState) => {
    if (shouldFetchParts(getState(), queryKey)) {
      let request = generateRequestFromKey(queryKey);
      return dispatch(fetchParts(request));
    } else {
      return Promise.resolve();
    }
  };
}

export function initialFetchFollowing() {
  return (dispatch, getState) => {
    return dispatch(fetchFollowingFromServer());
  };
}

function fetchFollowingFromServer() {
  return function (dispatch) {
    dispatch(requestFollowing());

    let promise = fetchFollowing();
    return promise
      .then(response =>
        dispatch(receiveFollowing(response.body))
      ).catch(function(err) { console.log('Response Error: ' + err); });
  };
}

export function generateKey(request) {
  const { query, filter, page } = request || { query: '', filter: SortFilters.MOST_FOLLOWED, page: 1 };
  return `${query}:${filter}:${page}`;
}

function generateRequestFromKey(key) {
  let split = key.split(':');
  return {
    query: split[0],
    filter: split[1],
    page: split[2]
  };
}

export function followOrUnfollowPart(partId) {
  return (dispatch, getState) => {
    let parts = getState().partsById
    let part = parts[partId];
    if (part.isFollowing === true) {
      return dispatch(doUnfollowPart(partId, parts));
    } else {
      return dispatch(doFollowPart(partId, parts));
    }
  };
}

function updatingFollow(partId, parts) {
  return { type: UPDATING_FOLLOW, partId, parts };
}

function followPart(partId, parts) {
  return { type: FOLLOW_PART, partId, parts };
}

function unfollowPart(partId, parts) {
  return { type: UNFOLLOW_PART, partId, parts };
}