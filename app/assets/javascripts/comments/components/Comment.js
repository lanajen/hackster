import React, { Component, PropTypes } from 'react';
import CommentForm from './CommentForm';
import FlagButton from '../../flag_button/app';
import smoothScroll from 'smoothscroll';

export default class Comment extends Component {
  constructor(props) {
    super(props);
    this.handleDeleteClick = this.handleDeleteClick.bind(this);
    this.handleReplyClick = this.handleReplyClick.bind(this);
    this.handlePost = this.handlePost.bind(this);
  }

  componentDidMount() {
    if ( this.props.scrollTo.scroll
      && this.props.scrollTo.element.id === this.props.comment.id
      && window ) {
      smoothScroll((React.findDOMNode(this).getBoundingClientRect().top + window.pageYOffset) - (window.innerHeight / 2), 500, () => {
        this.props.toggleScrollTo(false, null);
      });
    }
  }

  handleDeleteClick(commentId, e) {
    if(window) {
      let confirm = window.confirm('Are you sure you want to delete this comment?');
      if(confirm) {
        this.props.deleteComment(commentId);
      } else {
        return;
      }
    }
  }

  handleReplyClick(id, e) {
    this.props.triggerReplyBox(true, id);
  }

  handlePost(comment) {
    this.props.postComment(comment, true);
  }

  handleExpandButtonClick() {

  }

  render() {
    const { avatarLink, body, commentable_id, commentable_type, createdAt, deleted, depth, id, parent_id, user_id, userName } = this.props.comment;
    let rootClass = depth === 0 ? 'comment' : 'comment comment-nested';
    let date = window ? window.moment(createdAt).fromNow() : createdAt;

    let deleteOrFlagButton = (user_id === this.props.currentUser.id || this.props.currentUser.isAdmin)
                           ? (<li className="default-hidden">
                                <a href="javascript:void(0);" onClick={this.handleDeleteClick.bind(this, id)}>Delete</a>
                              </li>)
                           : (<li className="default-hidden">
                                <FlagButton currentUserId={this.props.currentUser.id} flaggable={{ type: "Comment", id: id }}/>
                              </li>);
    let replyButton = this.props.parentIsDeleted === false
                ? (<li>
                    <a href="javascript:void(0);" onClick={this.handleReplyClick.bind(this, parent_id || id)}>{depth === 0 ? 'Reply' : 'Reply to conversation'}</a>
                    </li>)
                : (<li className="text-muted">(Discussion closed)</li>);
    let actions = this.props.currentUser.id
                ? (<ul className="comment-actions">
                    {replyButton}
                    {deleteOrFlagButton}
                  </ul>)
                : (null);

    let replyBox = (this.props.replyBox.show && this.props.replyBox.id === id)
                 ? (<div className="reply-box">
                      <div className="reply-box-center-line">
                      </div>
                      <CommentForm parentId={parent_id || id} commentable={{ id: commentable_id, type: commentable_type }} onPost={this.handlePost} formData={this.props.formData} />
                    </div>)
                 : (null);

    let comment = depth === 0 && deleted === true
                ? (<div>
                    <div className={rootClass}>
                      <div className="comment-title">
                        <div className="avatar" dangerouslySetInnerHTML={{__html: avatarLink}}></div>
                        <div className="profile-name">
                          <h4>
                            <strong dangerouslySetInnerHTML={{__html: userName}}></strong>
                          </h4>
                          <span className="text-muted comment-date">{date}</span>
                        </div>
                      </div>
                      <div className="comment-body">
                        This comment has been deleted.
                      </div>
                    </div>
                    {this.props.children}
                  </div>)
                : (<div>
                    <div className={rootClass}>
                      <div className="comment-title">
                        <div className="avatar" dangerouslySetInnerHTML={{__html: avatarLink}}></div>
                        <div className="profile-name">
                          <h4>
                            <strong dangerouslySetInnerHTML={{__html: userName}}></strong>
                          </h4>
                          <span className="text-muted comment-date">{date}</span>
                        </div>
                      </div>
                      <div className="comment-body" dangerouslySetInnerHTML={{__html: body}}></div>
                      {actions}
                    </div>
                    {this.props.children}
                    {replyBox}
                  </div>);

    return (comment);
  }
}

Comment.PropTypes = {
  comment: PropTypes.object.isRequired,
  children: PropTypes.array,
  currentUser: PropTypes.object.isRequired,
  deleteComment: PropTypes.func.isRequired,
  formData: PropTypes.object.isRequired,
  handlePost: PropTypes.func.isRequired,
  postComment: PropTypes.func.isRequired,
  replyBox: PropTypes.object.isRequired,
  scrollTo: PropTypes.object.isRequired,
  toggleScrollTo: PropTypes.func.isRequired,
  triggerReplyBox: PropTypes.func.isRequired
};