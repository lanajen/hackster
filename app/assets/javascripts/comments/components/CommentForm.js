import React, { Component } from 'react';
import TextArea from './TextArea';

export default class CommentForm extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div>
        <TextArea />
        <button className="btn btn-primary">Post</button>
      </div>
    );
  }
}