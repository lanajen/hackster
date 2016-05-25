import request from 'superagent';
import { getApiPath, getApiToken } from '../../utils/Utils';

module.exports = {
  fetchReviewThread(projectId) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .get(`${getApiPath()}/private/review_threads`)
          .set('Authorization', `Bearer ${token}`)
          .query({ project_id: projectId })
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      }, true);
    });
  },

  postDecision(decision, projectId) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .post(`${getApiPath()}/private/review_decisions`)
          .set('Authorization', `Bearer ${token}`)
          .send({ review_decision: decision, project_id: projectId })
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      }, true);
    });
  },
};