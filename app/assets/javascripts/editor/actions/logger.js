import Request from '../utils/Requests';
import { Logger } from '../constants/ActionTypes';
import _ from 'lodash';

function addLog(log) {
  return {
    type: Logger.addLog,
    log
  };
}

export function postErrorLog(error, csrfToken) {
  return function(dispatch, getState) {
    const logger = getState().logger;

    if(logger.msg !== error.msg) {
      return Request.postErrorLog(error, csrfToken)
        .then(res => {
          dispatch(addLog(error));
        })
        .catch(err => console.log('postErrorLog Error: ', err));
    }
  };
}