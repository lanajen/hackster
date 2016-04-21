import request from 'superagent';
import { getApiPath } from '../utils/Utils';

export function fetchSubmissions() {
  return new Promise((resolve, reject) => {
    request
      .get(`${getApiPath()}/submissions`)
      .end((err, res) => {
        err ? reject(err) : resolve(res);
      });
  });
}

export function postActivePhase(phase) {
  return new Promise((resolve, reject) => {
    request
      .put(`${getApiPath()}/phases/${phase}`)
      .withCredentials()
      .end((err, res) => {
        err ? reject(err) : resolve(res);
      });
  });
}