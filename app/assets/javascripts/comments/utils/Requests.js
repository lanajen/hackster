import request from 'superagent';
import { getApiPath } from '../../utils/Utils';

export default {

  getComments(commentable) {
    return new Promise((resolve, reject) => {
      request(`${getApiPath()}/private/comments`)
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
        .del(`${getApiPath()}/private/comments/${id}`)
        .set('X-CSRF-Token', csrfToken)
        .withCredentials()
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.comment);
        });
    });
  },

  updateComment(comment, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .put(`${getApiPath()}/private/comments/${comment.comment.id}`)
        .set('X-CSRF-Token', csrfToken)
        .send(comment)
        .withCredentials()
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.comment);
        });
    });
  },

  postLike(id, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .post(`${getApiPath()}/private/likes`)
        .set('X-CSRF-Token', csrfToken)
        .send({ comment_id: id })
        .withCredentials()
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.liked);
        });
    });
  },

  deleteLike(id, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .del(`${getApiPath()}/private/likes`)
        .set('X-CSRF-Token', csrfToken)
        .send({ comment_id: id })
        .withCredentials()
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.liked);
        });
    });
  }
}