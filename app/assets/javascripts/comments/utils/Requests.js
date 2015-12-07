import request from 'superagent';

export default {

  getComments(commentable) {
    return new Promise((resolve, reject) => {
      request('/api/v1/comments')
        .query({ id: commentable.id })
        .query({ type: commentable.type })
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.comments);
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

  deleteComment(id, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .del('/api/v1/comments')
        .set('X-CSRF-Token', csrfToken)
        .query({ id: id })
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.comment);
        });
    });
  }
}