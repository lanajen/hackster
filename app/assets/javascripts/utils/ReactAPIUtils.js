import request from 'superagent';

module.exports = {

  addList(name) {
    return new Promise((resolve, reject) => {
      request
        .post('/api/v1/lists')
        .send({ group: { full_name: name } })
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  addToFollowing(id, type, source, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .post('/api/v1/followers')
        .set('X-CSRF-Token', csrfToken)
        .set('Accept', 'application/javascript')
        .query({button: 'button_shorter'})
        .query({followable_id: id})
        .query({followable_type: type})
        .query({source: source})
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  checkJob(jobId) {
    return new Promise((resolve, reject) => {
      request
        .get('/api/v1/jobs/' + jobId)
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  generateCSV(url) {
    return new Promise((resolve, reject) => {
      request
        .get(url)
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  getFileDetails(id) {
    return new Promise((resolve, reject) => {
      request
        .get(`/api/v1/files/${id}`)
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  fetchCurrentUser() {
    return new Promise((resolve, reject) => {
      request
        .get('/api/v1/me')
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.user);
        });
    });
  },

  fetchFollowing(csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .get('/api/v1/followers')
        .set('X-CSRF-Token', csrfToken)
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  fetchLists(projectId) {
    return new Promise((resolve, reject) => {
      request
        .get('/api/v1/lists')
        .query({ project_id: projectId })
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  fetchNotifications(csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .get('/api/v1/notifications')
        .set('X-CSRF-Token', csrfToken)
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  fetchReviewThread(projectId) {
    return new Promise((resolve, reject) => {
      request
        .get('/api/v1/review_threads')
        .query({ project_id: projectId })
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  flagContent(flaggableType, flaggableId, userId) {
    return new Promise((resolve, reject) => {
      request
        .post('/api/v1/flags')
        .send({flag: { flaggable_type: flaggableType,  flaggable_id: flaggableId,  user_id: userId} })
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  launchJob(jobType, userId) {
    return new Promise((resolve, reject) => {
      request
        .post('/api/v1/jobs')
        .send({ type: jobType, user_id: userId })
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  postComment(comment, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .post('/api/v1/comments')
        .set('X-CSRF-Token', csrfToken)
        .send(comment)
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.comment);
        });
    });
  },

  postDecision(decision, projectId) {
    return new Promise((resolve, reject) => {
      request
        .post('/api/v1/review_decisions')
        .send({ review_decision: decision, project_id: projectId })
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  removeFromFollowing(id, type, source, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .del('/api/v1/followers')
        .set('X-CSRF-Token', csrfToken)
        .set('Accept', 'application/javascript')
        .query({button: 'button_shorter'})
        .query({followable_id: id})
        .query({followable_type: type})
        .query({source: source})
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  toggleProjectInList(requestType, listId, projectId) {
    return new Promise((resolve, reject) => {
      request(requestType, '/api/v1/lists/' + listId + '/projects')
        .send({ project_id: projectId })
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  }
};