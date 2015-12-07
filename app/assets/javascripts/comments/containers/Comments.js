import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as CommentsActions from '../actions/comments';
import Comments from '../components/Comments';
import CommentForm from '../components/CommentForm';

class CommentsContainer extends Component {

  constructor(props) {
    super(props);
    this.handleCommentPost = this.handleCommentPost.bind(this);
  }

  componentWillMount() {
    this.props.actions.getInitialComments(this.props.commentable);
    this.props.actions.getCurrentUser();
  }

  handleCommentPost(comment) {
    this.props.actions.postComment(comment, false);
    this.props.actions.toggleFormData(true, null);
  }

  render() {
    let initialForm = this.props.commentStore.user.id !== null
                    ? (<CommentForm parentId={null} commentable={this.props.commentable} onPost={this.handleCommentPost} formData={this.props.commentStore.formData} />)
                    : (null);
    return (
      <div className="r-comments">
        {initialForm}
        <Comments actions={this.props.actions} commentStore={this.props.commentStore} />
      </div>
    );
  }
}

CommentsContainer.PropTypes = {
  commentable: PropTypes.object
};

function mapStateToProps(state) {
  return {
    commentStore: state.comments
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(Object.assign({}, CommentsActions), dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(CommentsContainer);