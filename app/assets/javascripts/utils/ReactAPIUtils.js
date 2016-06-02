import request from 'superagent';
import { getApiPath, getApiToken } from './Utils';

module.exports = {
  addList(name) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .post(`${getApiPath()}/v2/lists`)
          .set('Authorization', `Bearer ${token}`)
          .send({ group: { full_name: name } })
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      }, true);
    });
  },

  addToFollowing(id, type, source) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .post(`${getApiPath()}/private/followers`)
          .set('Authorization', `Bearer ${token}`)
          .query({button: 'button_shorter'})
          .query({followable_id: id})
          .query({followable_type: type})
          .query({source: source})
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      }, true);
    });
  },

  checkJob(jobId) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .get(`${getApiPath()}/private/jobs/${jobId}`)
          .set('Authorization', `Bearer ${token}`)
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      });
    });
  },

  getCSRFTokenFromApi() {
    return new Promise((resolve, reject) => {
      request
        .get(`${getApiPath()}/private/csrf.txt`)
        .set('Accept', 'text/plain')
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res.text);
        });
    });
  },

  fetchCurrentUser() {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .get(`${getApiPath()}/private/me`)
          .set('Authorization', `Bearer ${token}`)
          .end((err, res) => {
            err ? reject(err) : resolve(res.body.user);
          });
      });
    });
  },

  fetchFollowing() {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .get(`${getApiPath()}/private/followers`)
          .set('Authorization', `Bearer ${token}`)
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      }, true);
    });
  },

  fetchLists(projectId) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .get(`${getApiPath()}/v2/lists`)
          .set('Authorization', `Bearer ${token}`)
          .query({ project_id: projectId })
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      }, true);
    });
  },

  launchJob(jobType, userId) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .post(`${getApiPath()}/private/jobs`)
          .set('Authorization', `Bearer ${token}`)
          .send({ type: jobType, user_id: userId })
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      });
    });
  },

  postComment(comment) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .post(`${getApiPath()}/v2/comments`)
          .set('Authorization', `Bearer ${token}`)
          .send(comment)
          .end((err, res) => {
            err ? reject(err) : resolve(res.body.comment);
          });
      }, true);
    });
  },

  removeFromFollowing(id, type, source) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .del(`${getApiPath()}/private/followers`)
          .set('Authorization', `Bearer ${token}`)
          .query({button: 'button_shorter'})
          .query({followable_id: id})
          .query({followable_type: type})
          .query({source: source})
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      }, true);
    });
  },

  toggleProjectInList(requestType, listId, projectId) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request(requestType, `${getApiPath()}/v2/lists/${listId}/projects`)
          .set('Authorization', `Bearer ${token}`)
          .send({ project_id: projectId })
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      }, true);
    });
  }
};
