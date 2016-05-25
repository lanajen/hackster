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
      request
        .post(`${getApiPath()}/private/followers`)
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
      request
        .get(`${getApiPath()}/private/followers`)
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
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

  fetchNotifications() {
    return new Promise((resolve, reject) => {
      request
        .get(`${getApiPath()}/private/notifications`)
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
      request
        .del(`${getApiPath()}/private/followers`)
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
      getApiToken(token => {
        request(requestType, `${getApiPath()}/v2/lists/${listId}/projects`)
          .set('Authorization', `Bearer ${token}`)
          .send({ project_id: projectId })
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      }, true);
    });
  },

  updateChallengeRegistration(challengeId, data) {
    return new Promise((resolve, reject) => {
      request
        .patch(`${getApiPath()}/private/challenge_registrations`)
        .send({ challenge_id: challengeId })
        .send(data)
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  }
};