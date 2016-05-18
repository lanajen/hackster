import request from 'superagent';
import { getApiPath } from '../../utils/Utils';
import getApiToken from '../../services/oauth';

export default {

  getComments(commentable, cacheVersion) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request(`${getApiPath()}/v2/comments`)
          .set('Authorization', `Bearer ${token}`)
          .query({ id: commentable.id })
          .query({ type: commentable.type })
          .query(cacheVersion && cacheVersion.length ? { v: cacheVersion } : {})
          .end((err, res) => {
            err ? reject(err) : resolve(res.body.comments);
          });
      });
    });
  },

  deleteComment(id) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .del(`${getApiPath()}/v2/comments/${id}`)
          .set('Authorization', `Bearer ${token}`)
          .end((err, res) => {
            err ? reject(err) : resolve(res.body.comment);
          });
      }, true);
    });
  },

  updateComment(comment) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .put(`${getApiPath()}/v2/comments/${comment.comment.id}`)
          .set('Authorization', `Bearer ${token}`)
          .send(comment)
          .end((err, res) => {
            err ? reject(err) : resolve(res.body.comment);
          });
      }, true);
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