import request from 'superagent';
import { getApiPath } from '../../utils/Utils';

export default {

  getComments(commentable) {
    return new Promise((resolve, reject) => {
      request(`${getApiPath()}/v1/comments`)
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
        .del(`${getApiPath()}/v1/comments/${id}`)
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
        .put(`${getApiPath()}/v1/comments/${comment.comment.id}`)
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
        .post(`${getApiPath()}/v1/likes`)
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
        .del(`${getApiPath()}/v1/likes`)
        .set('X-CSRF-Token', csrfToken)
        .send({ comment_id: id })
        .withCredentials()
        .end((err, res) => {
          err ? reject(err) : resolve(res.body.liked);
        });
    });
  }
}