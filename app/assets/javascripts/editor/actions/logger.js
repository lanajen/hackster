import Request from '../utils/Requests';

export function postErrorLog(error, csrfToken) {
  return function(dispatch, getState) {
    return Request.postErrorLog(error, csrfToken)
      .then(res => true)
      .catch(err => console.log('postErrorLog Error: ', err));
  };
}