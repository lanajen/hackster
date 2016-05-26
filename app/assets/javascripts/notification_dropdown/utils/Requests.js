import request from 'superagent';
import { getApiPath, getApiToken } from '../../utils/Utils';

module.exports = {
  fetchNotifications() {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .get(`${getApiPath()}/private/notifications`)
          .set('Authorization', `Bearer ${token}`)
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      }, true);
    });
  }
};