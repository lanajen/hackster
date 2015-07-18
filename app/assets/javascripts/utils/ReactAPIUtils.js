import request from 'superagent';

module.exports = {

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

  flagContent(csrfToken, flaggableType, flaggableId, userId) {
    return new Promise((resolve, reject) => {
      request
        .post('/api/v1/flags')
        .set('X-CSRF-Token', csrfToken)
        .send({flag: { flaggable_type: flaggableType,  flaggable_id: flaggableId,  user_id: userId} })
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  }

};