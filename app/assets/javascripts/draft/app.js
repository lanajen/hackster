import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';

import request from 'superagent';
import Utils from '../editor/utils/DOMUtils';
import { getApiPath } from '../utils/Utils';
import { Draftster, DraftsterUtils } from '@hacksterio/draftster';

function getStory(projectId) {
  return new Promise((resolve, reject) => {
    request(`${getApiPath()}/private/projects/${projectId}/description`)
      .withCredentials()
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
  });
}

const App = props => {

  const config = {
    handleImageUpload(images, callback) {
      images.forEach((image, index) => {
        const err = null;
        console.log("GOT EM");
        callback(err, {...image, id: index});
      });
    },

    hideEditor() {
      if(window && window.location.hash !== '#story') {
        return true;
      }

      return false;
    },

    setInitialContent() {
      return getStory(props.projectId);
    }
  };

  return (
    <Draftster config={config} {...props}/>
  );
}

export default App;