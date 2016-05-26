import request from 'superagent';
import { getApiPath, getApiToken } from '../../utils/Utils';

module.exports = {
  generateCSV(url) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .get(`${getApiPath()}${url}`)
          .set('Authorization', `Bearer ${token}`)
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      }, true);
    });
  },

  getFileDetails(id) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .get(`${getApiPath()}/private/files/${id}`)
          .set('Authorization', `Bearer ${token}`)
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      }, true);
    });
  }
};