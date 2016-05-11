import request from 'superagent';

import { getS3AuthData, postToS3, postURLToServer } from '../utils/Images';
import { getApiPath, getCSRFToken } from '../utils/Utils';
import { parseDescription, expandPreBlocks } from './parsers/description';

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
          const story = res.body.story.map(item => {
            if(item.type === 'CE') {
              item.json = expandPreBlocks(item.json);
            }
            return item;
          });

          resolve(story);
        } else {
          reject('Error Fetching Story!');
        }
    });
  });
}

export function uploadImageToServer(image, S3URL, AWSKey, projectId, modelType) {
  return new Promise((resolve, reject) => {
    return getS3AuthData(image.name)
      .then(S3Data => {
        return postToS3(S3Data, image, S3URL, AWSKey);
      })
      .then(url => {
        return postURLToServer(url, projectId, modelType, getCSRFToken(), 'image');
      })
      .then(res => {
        resolve({ ...image, id: res.body.id });
      })
      .catch(err => {
        reject(err);
      });
  });
}

