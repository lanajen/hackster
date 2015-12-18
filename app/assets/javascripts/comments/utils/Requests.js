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

  deleteComment(id, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .del(`/api/v1/comments/${id}`)
        .set('X-CSRF-Token', csrfToken)
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.comment);
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

  updateComment(comment, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .put(`/api/v1/comments/${comment.comment.id}`)
        .set('X-CSRF-Token', csrfToken)
        .send(comment)
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.comment);
        });
    });
  },

  postLike(id, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .post('/api/v1/likes')
        .set('X-CSRF-Token', csrfToken)
        .send({ comment_id: id })
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.liked);
        });
    });
  },

  deleteLike(id, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .del('/api/v1/likes')
        .set('X-CSRF-Token', csrfToken)
        .send({ comment_id: id })
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.liked);
        });
    });
  }
}