import request from 'superagent';
import Utils from './DOMUtils';
import { getApiPath, getApiToken } from '../../utils/Utils';

export default {
  getStory(projectId, csrfToken) {
    return new Promise((resolve, reject) => {
      getApiToken(token => {
        request(`${getApiPath()}/v2/projects/${projectId}/description`)
          .set('Authorization', `Bearer ${token}`)
          .end((err, res) => {
            if(err) reject(err);

            if(res.body && res.body.description !== null) {
              let description = res.body.description;

              if(!description.length) {
                resolve([]);
              } else {
                let parsedHtml = Utils.parseDescription(description, { initialParse: true });

                parsedHtml.then(parsed => {
                  resolve(parsed);
                }).catch(err => {
                  reject(err);
                });
              }

            } else if(res.body && res.body.story !== null) {
              resolve(res.body.story);
            } else {
              reject('Error Fetching Story!');
            }
        });
      }, true);
    });
  },

  postErrorLog(error, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .post(`${getApiPath()}/private/error_logs`)
        .set('X-CSRF-Token', csrfToken)
        .withCredentials()
        .send({ error: error })
        .end((err, res) => {
          err ? reject('Post Error Log Error: ', err) : resolve(res.body);
        });
    })
  }
};