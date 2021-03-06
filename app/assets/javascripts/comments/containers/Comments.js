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
    this.props.actions.getInitialComments(this.props.commentable, this.props.cacheVersion);
    this.props.actions.getCurrentUser();
  }

  handleCommentPost(comment) {
    this.props.actions.postComment(comment, false);
    this.props.actions.toggleFormData(true, null);
  }

  render() {
    let initialForm = this.props.commentStore.user.id
                    ? (this.props.commentStore.user.isConfirmed
                        ? <CommentForm parentId={null} commentable={this.props.commentable} onPost={this.handleCommentPost} formData={this.props.commentStore.formData} placeholder={this.props.placeholder} />
                        : (<div className="alert alert-warning">
                            <p>Please confirm your email before commenting. Haven't received a confirmation email? <a href="/users/confirmation/new" className="alert-link">Resend</a>. Contact us at help@hackster.io for help.
                            </p>
                          </div>))
                    : (null);
    let comments = this.props.commentStore.fetchedInitialComments
                 ? (<Comments actions={this.props.actions} commentStore={this.props.commentStore} placeholder={this.props.placeholder} commentable={this.props.commentable} />)
                 : (<div style={{ textAlign: 'center' }}><i className="fa fa-spinner fa-2x fa-spin"></i></div>);
    return (
      <div className="r-comments">
        {initialForm}
        {comments}
      </div>
    );
  }
}

CommentsContainer.PropTypes = {
  commentable: PropTypes.object.isRequired,
  placeholder: PropTypes.string.isRequired,
  cacheVersion: PropTypes.string
};

CommentsContainer.defaultProps = {
  cacheVersion: ''
}

function mapStateToProps(state) {
  return {
    commentStore: state.comments
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(Object.assign({}, CommentsActions), dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(CommentsContainer);