import request from 'superagent';
import { getApiPath } from '../utils/Utils';

export function fetchSubmissions() {
  return new Promise((resolve, reject) => {
    request
      .get(`${getApiPath()}/mouser/submissions`)
      .end((err, res) => {
        err ? reject(err) : resolve(res);
      });
  });
}