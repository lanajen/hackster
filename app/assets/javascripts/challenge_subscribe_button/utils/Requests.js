import request from 'superagent';
import { getApiPath, getApiToken } from '../../utils/Utils';

module.exports = {
  updateChallengeRegistration(challengeId, data) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request
          .patch(`${getApiPath()}/private/challenge_registrations`)
          .set('Authorization', `Bearer ${token}`)
          .send({ challenge_id: challengeId })
          .send(data)
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      }, true);
    });
  }
};