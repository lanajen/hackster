import request from 'superagent';

const Requests = {

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
  }
}

export default Requests;
