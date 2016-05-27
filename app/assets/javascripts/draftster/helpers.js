import request from 'superagent';

import { getS3AuthData, postToS3, postURLToServer, postRemoteURL, pollJob } from '../utils/Images';
import { getApiPath, getApiToken } from '../utils/Utils';
import { parseDescription, expandPreBlocks } from './parsers/description';

export function getStory(projectId) {
  return new Promise((resolve, reject) => {
    getApiToken(token => {
      request(`${getApiPath()}/private/projects/${projectId}/description`)
        .set('Authorization', `Bearer ${token}`)
        .end((err, res) => {
          if(err) reject(err);

          if(res.body && res.body.description !== null) {
            const description = res.body.description;

            !description.length
              ? resolve('')
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

            resolve(story.length ? story : '');
          } else {
            reject('Error Fetching Story!');
          }
      }, true);
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
        return postURLToServer(url, projectId, modelType, 'image');
      })
      .then(res => {
        resolve({ ...image, id: res.body.id });
      })
      .catch(err => reject(err));
  });
}

export function processRemoteImage(image) {
  return new Promise((resolve, reject) => {
    return postRemoteURL(image.url, 'image')
      .then(body => {
        image = { ...image, id: body.id };
        return pollJob(body['job_id']);
      })
      .then(status => {
        resolve(image);
      })
      .catch(err => reject(err));
  });
}

