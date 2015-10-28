import React, { Component } from 'react';
import TextArea from './TextArea';

export default class CommentForm extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div className="comments-form">
        <TextArea />
        <div className="comments-form-button-container">
          <button className="btn btn-primary">Post</button>
        </div>
      </div>
    );
  }
}