import request from 'superagent';
import { getApiPath } from './Utils';

module.exports = {

  addList(name) {
    return new Promise((resolve, reject) => {
      request
        .post(`${getApiPath()}/private/lists`)
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
        .post(`${getApiPath()}/private/followers`)
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
        .get(`${getApiPath()}/private/jobs/${jobId}`)
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
        .get(`${getApiPath()}/private/files/${id}`)
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  fetchCurrentUser() {
    return new Promise((resolve, reject) => {
      request
        .get(`${getApiPath()}/private/me`)
        .withCredentials()
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.user);
        });
    });
  },

  fetchFollowing(csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .get(`${getApiPath()}/private/followers`)
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
        .get(`${getApiPath()}/private/lists`)
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
        .get(`${getApiPath()}/private/notifications`)
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
        .get(`${getApiPath()}/private/review_threads`)
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
        .post(`${getApiPath()}/private/flags`)
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
        .post(`${getApiPath()}/private/jobs`)
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
        .post(`${getApiPath()}/private/comments`)
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
        .post(`${getApiPath()}/private/review_decisions`)
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
        .del(`${getApiPath()}/private/followers`)
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
      request(requestType, `${getApiPath()}/private/lists/${listId}/projects`)
        .send({ project_id: projectId })
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  }
};