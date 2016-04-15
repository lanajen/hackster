import request from 'superagent';
import { getApiPath } from '../utils/Utils';

export function fetchSubmissions() {
  return new Promise((resolve, reject) => {
    request
      .get(`${getApiPath()}/api/submissions`)
      .end((err, res) => {
        err ? reject(err) : resolve(res);
      });
  });
}

export function postActivePhase(phase) {
  return Promise.resolve(phase);
  return new Promise((resolve, reject) => {
    request
      .post(`${getApiPath()}/api/phase`)
      .end((err, res) => {
        err ? reject(err) : resolve(res);
      });
  });
}