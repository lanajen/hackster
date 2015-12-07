import React, { Component, PropTypes } from 'react';
import CommentForm from './CommentForm';
import Comment from './Comment';

export default class Comments extends Component {
  constructor(props) {
    super(props);
    this.deleteComment = this.deleteComment.bind(this);
    this.triggerReplyBox = this.triggerReplyBox.bind(this);
  }

  deleteComment(id) {
    this.props.actions.deleteComment({ id: id, csrfToken: this.props.commentStore.user.csrfToken });
  }

  triggerReplyBox(show, id) {
    this.props.actions.triggerReplyBox(show, id);
  }

  render() {
    let user = this.props.commentStore.user;
    const comments = this.props.commentStore.comments.length > 0
                   ? this.props.commentStore.comments.map((comment, index) => {
      let children = comment.children.map((child, i) => {
        return <Comment key={i}
                        comment={child}
                        children={null}
                        currentUser={user}
                        formData={this.props.commentStore.formData}
                        deleteComment={this.deleteComment}
                        postComment={this.props.actions.postComment}
                        replyBox={this.props.commentStore.replyBox}
                        scrollTo={this.props.commentStore.scrollTo}
                        toggleFormData={this.props.actions.toggleFormData}
                        toggleScrollTo={this.props.actions.toggleScrollTo}
                        triggerReplyBox={this.triggerReplyBox} />
      });
      return <Comment key={index}
                      comment={comment.root}
                      children={children}
                      currentUser={user}
                      formData={this.props.commentStore.formData}
                      deleteComment={this.deleteComment}
                      postComment={this.props.actions.postComment}
                      replyBox={this.props.commentStore.replyBox}
                      scrollTo={this.props.commentStore.scrollTo}
                      toggleFormData={this.props.actions.toggleFormData}
                      toggleScrollTo={this.props.actions.toggleScrollTo}
                      triggerReplyBox={this.triggerReplyBox} />
                    })
                    : ( <div>Be the first to comment!</div> );

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