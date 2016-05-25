import request from 'superagent';
import { getApiPath, getApiToken } from '../../utils/Utils';

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

  postLike(id) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .post(`${getApiPath()}/v2/likes`)
          .set('Authorization', `Bearer ${token}`)
          .send({ id: id })
          .send({ type: 'Comment' })
          .end((err, res) => {
            err ? reject(err) : resolve(res.body.liked);
          });
      }, true);
    });
  },

  deleteLike(id) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .del(`${getApiPath()}/v2/likes`)
          .set('Authorization', `Bearer ${token}`)
          .send({ id: id })
          .send({ type: 'Comment' })
          .end((err, res) => {
            err ? reject(err) : resolve(res.body.liked);
          });
      }, true);
    });
  }
}