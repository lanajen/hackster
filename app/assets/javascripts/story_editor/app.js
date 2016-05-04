import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';

import { Draftster, DraftsterUtils } from '@hacksterio/draftster';
import { getStory, uploadImageToServer } from '../draftster/helpers';
import convertToJSONModel from '../draftster/convertToJSONModel';

const config = {
  handleImageUpload(image, callback) {
    return uploadImageToServer(image, props.S3BucketURL, props.AWSAccessKeyId, props.projectId)
      .then(mergedImage => callback(null, mergedImage))
      .catch(err => callback(err, image));
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

class StoryEditor extends Component {
  constructor(props) {
    super(props);
  }

  componentWillMount() {
    this.form = document.querySelector('form.story-form');

    /** Binds our callback when submit button is pressed. */
    this.form.addEventListener('pe:submit', this.handleSubmit);
    this.form.addEventListener('pe:complete', this.handleSubmitComplete);
  }

  componentWIllUnmount() {
    this.form = null;
  }

  render() {
    return <Draftster config={config} {...this.props} />;
  }
}

StoryEditor.PropTypes = {
  AWSAccessKeyId: PropTypes.string.isRequired,
  projectId: PropTypes.number.isRequired,
  S3BucketURL: PropTypes.string.isRequired
};

export default StoryEditor;