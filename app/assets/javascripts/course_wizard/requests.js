import request from 'superagent';

export default {
  getOptions: function(query) {
    return new Promise((resolve, reject) => {
      request
        .get('/api/v1/groups')
        .query(query)
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
        .end((err, res) => {
          err ? reject(err) : resolve(res.body);
        });
    });
  }
};