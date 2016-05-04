import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';

import { Draftster, DraftsterUtils } from '@hacksterio/draftster';
import { getStory, uploadImageToServer } from '../draftster/helpers';
import convertToJSONModel from '../draftster/convertToJSONModel';

class StoryEditor extends Component {
  constructor(props) {
    super(props);

    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleSubmitComplete = this.handleSubmitComplete.bind(this);

    this.config = {
      editorIsBusy(bool) {
        const container = document.querySelectorAll('.pe-save')[0];
        const button = container.querySelector('.pe-submit');

        if(bool) {
          button.innerText = 'Uploading image';
          button.setAttribute('disabled', true);
        } else {
          button.innerText = 'Save changes';
          button.removeAttribute('disabled');
        }
      },

      handleImageUpload(image, callback) {
      console.log("IMAGE", image);
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
  }

  componentDidMount() {
    this.form = document.querySelector('form.story-form');

    /** Binds our callback when submit button is pressed. */
    this.form.addEventListener('pe:submit', this.handleSubmit);
    this.form.addEventListener('pe:complete', this.handleSubmitComplete);
  }

  componentWillUnmount() {
    this.form.removeEventListener('pe:submit', this.handleSubmit);
    this.form.removeEventListener('pe:complete', this.handleSubmitComplete);
    this.form = null;
  }

  handleSubmit(e) {
    convertToJSONModel(DraftsterUtils.getEditorContent())
      .then(json => {
        // Appends a story_json input to the hidden form.
        let input = document.createElement('input');
        input.type = 'hidden';
        input.name = 'base_article[story_json]';
        input.id = 'story-json-input';
        input.value = JSON.stringify(json);
        this.form.insertBefore(input, this.form.firstChild);

        // Submit the hidden form (projects.js line:243 via CustomEvent on pe.saveChanges).
        // NOTE: Use the form on the event.  this.form will trigger a redirect.
        e.detail.form.submit();
      })
      .catch(err => console.log("err", err));
  }

  handleSubmitComplete(e) {
    const input = document.getElementById('story-json-input');
    this.form.contains(input) ? this.form.removeChild(input) : false;

    /** Reserialize the form so pe && jQuery know we have NO unsaved changes. **/
    if (window && window.pe) {
      window.pe.serializeForm();
      window.pe.updateChecklist();
    }
    DraftsterUtils.triggerMessenger('Saved successfully!', 'success');
  }

  render() {
    return <Draftster config={this.config} {...this.props} />;
  }
}

StoryEditor.PropTypes = {
  AWSAccessKeyId: PropTypes.string.isRequired,
  projectId: PropTypes.number.isRequired,
  S3BucketURL: PropTypes.string.isRequired
};

export default StoryEditor;