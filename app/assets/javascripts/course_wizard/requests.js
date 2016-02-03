import request from 'superagent';
import { getApiPath } from '../utils/Utils'

export default {
  getOptions: function(query) {
    return new Promise((resolve, reject) => {
      request
        .get(`${getApiPath()}/private/groups`)
        .query(query)
        .withCredentials()
        .end((err, res) => {
          err ? reject(err) : resolve(res.body);
        });
    });
  },

  postForm: function(form, endpoint, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .post(endpoint)
        .set('X-CSRF-Token', csrfToken)
        .send({ group: form })
        .withCredentials()
        .end((err, res) => {
          err ? reject(err) : resolve(res.body);
        });
    });
  }
};