import React, { Component, PropTypes } from 'react';
import CommentForm from './CommentForm';
import Comment from './Comment';

export default class Comments extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    const comments = this.props.commentStore.comments.map((comment, index) => {
      let children = comment.children.map((child, i) => {
        return <Comment key={i} comment={child} children={null} />
      });
      return <Comment key={index} comment={comment.root} children={children} />
    });
    return (
      <div>
        {comments}
      </div>
    );
  }
}

Comments.PropTypes = {
  actions: React.PropTypes.object,
  commentStore: React.PropTypes.object
};