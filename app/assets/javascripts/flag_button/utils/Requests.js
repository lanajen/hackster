import request from 'superagent';
import { getApiPath, getApiToken } from '../../utils/Utils';

module.exports = {
  flagContent(flaggableType, flaggableId, userId) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .post(`${getApiPath()}/private/flags`)
          .set('Authorization', `Bearer ${token}`)
          .send({flag: { flaggable_type: flaggableType,  flaggable_id: flaggableId,  user_id: userId} })
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      });
    });
  }
};