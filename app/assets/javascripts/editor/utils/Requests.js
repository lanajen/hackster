import request from 'superagent';
import Utils from './DOMUtils';
import { getApiPath } from '../../utils/Utils';

export default {
  getStory(projectId, csrfToken) {
    return new Promise((resolve, reject) => {
      request(`${getApiPath()}/v1/projects/${projectId}/description`)
        .query({ id: projectId })
        .withCredentials()
        .end((err, res) => {
          if(err) reject(err);

          if(res.body && res.body.description !== null) {
            let description = res.body.description;

            if(!description.length) {
              resolve([]);
            } else {
              let parsedHtml = Utils.parseDescription(description, projectId, csrfToken);

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
    });
  }
};