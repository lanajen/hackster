import request from 'superagent';

export default {

  getComments(commentable, csrfToken) {
    return new Promise((resolve, reject) => {
      request('/api/v1/comments')
        .set('X-CSRF-Token', csrfToken)
        .query({ id: commentable.id })
        .query({ type: commentable.type })
        .end((err, res) => {
          if(err) reject(err);

          resolve(res.body.comments);
        });
    });
  },

  postComment(comment) {
    return new Promise((resolve, reject) => {
      request
        .post('/api/v1/comments')
        .send(comment)
        .end((err, res) => {
          if(err) reject(err);

          resolve(res);
        });
    });
  }
}