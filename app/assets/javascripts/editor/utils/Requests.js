import request from 'superagent';
import Utils from './DOMUtils';
import ImageUitls from '../../utils/Images';

export default {

  getStory(projectId, csrfToken) {
    return new Promise((resolve, reject) => {
      request(`/api/v1/projects/${projectId}/description`)
        .set('X-CSRF-Token', csrfToken)
        .query({ id: projectId })
        .end((err, res) => {
          if(err) reject(err);

          if(res.body.description !== null && res.body.story === null) {
            let parsedHtml = Utils.parseDescription(res.body.description, projectId, csrfToken);

            parsedHtml.then(parsed => {
              resolve(parsed);
            }).catch(err => {
              reject(err);
            });

          } else {
            resolve(res.body.story);
          }
      });
    });
  },

  fetchImageAndTransform(videoData, projectId, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .post(`/api/v1/projects/${projectId}/video_data`)
        .set('X-CSRF-Token', csrfToken)
        .send({ videoData: videoData })
        .end((err, res) => {
          if(err) reject(err);
          let image = res.body ? res.body.poster : null;

          if(image === null) {
            // TODO: Handle err;
            reject('Error');
          }

          ImageUitls.handleImageResize(image, function(imageData) {
            resolve([Object.assign({}, imageData, videoData)]); 
          });

        });
    });
  }

};