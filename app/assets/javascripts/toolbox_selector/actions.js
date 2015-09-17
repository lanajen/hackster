import request from 'superagent';

export const SELECT_PARTS = 'SELECT_PARTS';
export const REQUEST_PARTS = 'REQUEST_PARTS';
export const RECEIVE_PARTS = 'RECEIVE_PARTS';
export const FOLLOW_PART = 'FOLLOW_PART';
export const UNFOLLOW_PART = 'UNFOLLOW_PART';

export const SortFilters = {
  ALPHABETICAL: 'alpha',
  MOST_FOLLOWED: 'owned',
  MOST_USED: 'used'
};

export function selectParts(request) {
  return {
    type: SELECT_PARTS,
    request: request
  };
}

export function requestParts(request) {
  return {
    type: REQUEST_PARTS,
    request: request
  };
}

export function receiveParts(request, response) {
  return {
    type: RECEIVE_PARTS,
    parts: response.parts,
    nextPage: response.next_page,
    request: request
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
      .query({ query: req.query, sort: SortFilters[req.filter], page: req.page })
      .end(function(err, res) {
        err ? reject(err) : resolve(res);
      });
  });
}

function shouldFetchParts(state, queryKey) {
  // console.log('METHOD', 'shouldFetchParts');
  // console.log('STATE', state);
  // console.log('REQUEST', request);
  // let key = generateKey(request);
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

export function generateKey(request) {
  // let query = request.query || '';
  // let filter = request.filter || SortFilters.MOST_FOLLOWED;
  // let page = request.page || 1;
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

export function followPart(partId) {
  return { type: FOLLOW_PART, partId };
}

export function unfollowPart(partId) {
  return { type: UNFOLLOW_PART, partId };
}