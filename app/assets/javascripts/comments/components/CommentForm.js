import React, { Component, PropTypes } from 'react';
import TextArea from './TextArea';

export default class CommentForm extends Component {
  constructor(props) {
    super(props);
    this.handlePostClick = this.handlePostClick.bind(this);
  }

  handlePostClick(e) {
    e.preventDefault();
    let form = {
      comment: {
        'raw_body': React.findDOMNode(this.refs.textarea).value,
        'parent_id': this.props.parentId
      },
      commentable: this.props.commentable
    };
    this.props.onPost(form);
  }

  render() {
    return (
      <div className="comments-form">
        <TextArea ref="textarea" />
        <div className="comments-form-button-container">
          <button className="btn btn-primary" onClick={this.handlePostClick}>Post</button>
        </div>
      </div>
    );
  }
}

CommentForm.PropTypes = {
  parentId: React.PropTypes.number
};