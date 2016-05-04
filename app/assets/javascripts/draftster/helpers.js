import request from 'superagent';

// import Utils from '../editor/utils/DOMUtils';
import { getS3AuthData, postToS3, postURLToServer } from '../utils/Images';
import { getApiPath, getCSRFToken } from '../utils/Utils';
import { parseDescription } from './parsers/description';

export function getStory(projectId) {
  return new Promise((resolve, reject) => {
    request(`${getApiPath()}/private/projects/${projectId}/description`)
      .withCredentials()
      .end((err, res) => {
        if(err) reject(err);

        if(res.body && res.body.description !== null) {
          const description = res.body.description;

          !description.length
            ? resolve([])
            : parseDescription(description, { initialParse: true })
                .then(parsed => {
                  resolve(parsed);
                })
                .catch(err => {
                  reject(err);
                });

        } else if(res.body && res.body.story !== null) {
          resolve(res.body.story);
        } else {
          reject('Error Fetching Story!');
        }
    });
  });
}

export function uploadImageToServer(image, S3URL, AWSKey, projectId) {
  return new Promise((resolve, reject) => {
    return getS3AuthData(image.name)
      .then(S3Data => {
        return postToS3(S3Data, image, S3URL, AWSKey);
      })
      .then(url => {
        return postURLToServer(url, projectId, getCSRFToken(), 'image', 'tmp-file-0');
      })
      .then(res => {
        resolve({ ...image, id: res.body.id });
      })
      .catch(err => {
        reject(err);
      });
  });
}

