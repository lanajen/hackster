import request from 'superagent';
import { getApiPath } from './Utils';

module.exports = {

  addList(name) {
    return new Promise((resolve, reject) => {
      request
        .post(`${getApiPath()}/v1/lists`)
        .send({ group: { full_name: name } })
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  addToFollowing(id, type, source, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .post(`${getApiPath()}/v1/followers`)
        .set('X-CSRF-Token', csrfToken)
        .set('Accept', 'application/javascript')
        .query({button: 'button_shorter'})
        .query({followable_id: id})
        .query({followable_type: type})
        .query({source: source})
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  checkJob(jobId) {
    return new Promise((resolve, reject) => {
      request
        .get(`${getApiPath()}/v1/jobs/${jobId}`)
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  generateCSV(url) {
    return new Promise((resolve, reject) => {
      request
        .get(`${getApiPath()}${url}`)
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  getFileDetails(id) {
    return new Promise((resolve, reject) => {
      request
        .get(`${getApiPath()}/v1/files/${id}`)
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  fetchCurrentUser() {
    return new Promise((resolve, reject) => {
      request
        .get(`${getApiPath()}/v1/me`)
        .withCredentials()
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.user);
        });
    });
  },

  fetchFollowing(csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .get(`${getApiPath()}/v1/followers`)
        .set('X-CSRF-Token', csrfToken)
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  fetchLists(projectId) {
    return new Promise((resolve, reject) => {
      request
        .get(`${getApiPath()}/v1/lists`)
        .query({ project_id: projectId })
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  fetchNotifications(csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .get(`${getApiPath()}/v1/notifications`)
        .set('X-CSRF-Token', csrfToken)
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  fetchReviewThread(projectId) {
    return new Promise((resolve, reject) => {
      request
        .get(`${getApiPath()}/v1/review_threads`)
        .query({ project_id: projectId })
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  flagContent(flaggableType, flaggableId, userId) {
    return new Promise((resolve, reject) => {
      request
        .post(`${getApiPath()}/v1/flags`)
        .send({flag: { flaggable_type: flaggableType,  flaggable_id: flaggableId,  user_id: userId} })
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  launchJob(jobType, userId) {
    return new Promise((resolve, reject) => {
      request
        .post(`${getApiPath()}/v1/jobs`)
        .send({ type: jobType, user_id: userId })
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  postComment(comment, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .post(`${getApiPath()}/v1/comments`)
        .set('X-CSRF-Token', csrfToken)
        .send(comment)
        .withCredentials()
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.comment);
        });
    });
  },

  postDecision(decision, projectId) {
    return new Promise((resolve, reject) => {
      request
        .post(`${getApiPath()}/v1/review_decisions`)
        .send({ review_decision: decision, project_id: projectId })
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  removeFromFollowing(id, type, source, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .del(`${getApiPath()}/v1/followers`)
        .set('X-CSRF-Token', csrfToken)
        .set('Accept', 'application/javascript')
        .query({button: 'button_shorter'})
        .query({followable_id: id})
        .query({followable_type: type})
        .query({source: source})
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  toggleProjectInList(requestType, listId, projectId) {
    return new Promise((resolve, reject) => {
      request(requestType, `${getApiPath()}/v1/lists/${listId}/projects`)
        .send({ project_id: projectId })
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  }
};