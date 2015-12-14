import React, { Component, PropTypes } from 'react';
import CommentForm from './CommentForm';
import Comment from './Comment';

export default class Comments extends Component {
  constructor(props) {
    super(props);
    this.deleteComment = this.deleteComment.bind(this);
    this.deleteLike = this.deleteLike.bind(this);
    this.postComment = this.postComment.bind(this);
    this.postLike = this.postLike.bind(this);
    this.triggerReplyBox = this.triggerReplyBox.bind(this);
  }

  componentWillUpdate(nextProps) {
    if(nextProps.commentStore.rootCommentsToDelete.length > 0) {
      nextProps.commentStore.rootCommentsToDelete.forEach(id => {
        this.deleteComment(id);
        this.props.actions.removeIdFromDeleteList(id);
      });
    }
  }

  deleteComment(id) {
    this.props.actions.deleteComment(id, this.props.commentStore.user.csrfToken);
  }

  postComment(comment) {
    this.props.actions.postComment(comment, true, this.props.commentStore.user.csrfToken);
    this.props.actions.toggleFormData(true, null);
  }

  deleteLike(commentId, parentId) {
    this.props.actions.deleteLike(commentId, parentId, this.props.commentStore.user.csrfToken);
  }

  postLike(commentId, parentId) {
    this.props.actions.postLike(commentId, parentId, this.props.commentStore.user.csrfToken);
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
                        deleteLike={this.deleteLike}
                        formData={this.props.commentStore.formData}
                        deleteComment={this.deleteComment}
                        placeholder={this.props.placeholder}
                        postComment={this.postComment}
                        postLike={this.postLike}
                        replyBox={this.props.commentStore.replyBox}
                        scrollTo={this.props.commentStore.scrollTo}
                        toggleScrollTo={this.props.actions.toggleScrollTo}
                        triggerReplyBox={this.triggerReplyBox}
                        parentIsDeleted={comment.root.deleted}
                        placeholder={this.props.placeholder} />
      });
      return <Comment key={index}
                      comment={comment.root}
                      children={children}
                      currentUser={user}
                      deleteLike={this.deleteLike}
                      formData={this.props.commentStore.formData}
                      deleteComment={this.deleteComment}
                      placeholder={this.props.placeholder}
                      postComment={this.postComment}
                      postLike={this.postLike}
                      replyBox={this.props.commentStore.replyBox}
                      scrollTo={this.props.commentStore.scrollTo}
                      toggleScrollTo={this.props.actions.toggleScrollTo}
                      triggerReplyBox={this.triggerReplyBox}
                      parentIsDeleted={false}
                      placeholder={this.props.placeholder} />
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
  actions: PropTypes.object,
  commentStore: PropTypes.object,
  placeholder: PropTypes.string
};