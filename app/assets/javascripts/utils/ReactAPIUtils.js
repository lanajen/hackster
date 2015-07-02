import request from 'superagent';

module.exports = {

  addToFollowing(id, type, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .post('/followers')
        .set('X-CSRF-Token', csrfToken)
        .set('Accept', 'application/javascript')
        .query({button: 'button_shorter'})
        .query({followable_id: id})
        .query({followable_type: type})
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  removeFromFollowing(id, type, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .del('/followers')
        .set('X-CSRF-Token', csrfToken)
        .set('Accept', 'application/javascript')
        .query({button: 'button_shorter'})
        .query({followable_id: id})
        .query({followable_type: type})
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  }

};