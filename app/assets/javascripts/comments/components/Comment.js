import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom'
import CommentForm from './CommentForm';
import FlagButton from '../../flag_button/app';
import LikeButton from './LikeButton';
import smoothScroll from '../utils/SmoothScroll';
import markdown from '../utils/Markdown'

export default class Comment extends Component {
  constructor(props) {
    super(props);
    this.handleDeleteClick = this.handleDeleteClick.bind(this);
    this.handleReplyClick = this.handleReplyClick.bind(this);
    this.handlePost = this.handlePost.bind(this);
    this.handleEditClick = this.handleEditClick.bind(this);
    this.dismissForm = this.dismissForm.bind(this);
    this.updateComment = this.updateComment.bind(this);

    this.state = { isEditing: false };
  }

  componentDidMount() {
    if (this.props.scrollTo.scroll
      && this.props.scrollTo.element.id === this.props.comment.id
      && window ) {
      smoothScroll((ReactDOM.findDOMNode(this).getBoundingClientRect().top + window.pageYOffset) - (window.innerHeight / 2), 500, () => {
        this.props.toggleScrollTo(false, null);
      });
    }
  }

  componentWillReceiveProps(nextProps) {
    if(nextProps.commentUpdated.id === this.props.comment.id) {
      this.dismissForm('Editing');
      this.props.toggleCommentUpdated();
    }
  }

  handleDeleteClick(commentId, e) {
    e.preventDefault();
    if (window) {
      let confirm = window.confirm('Are you sure you want to delete this comment?');
      if (confirm) {
        this.props.deleteComment(commentId);
      } else {
        return;
      }
    }
  }

  handleReplyClick(id, e) {
    e.preventDefault();
    this.props.triggerReplyBox(true, id);
  }

  handlePost(comment) {
    this.props.postComment(comment, this.props.comment.id);
  }

  handleEditClick(e) {
    e.preventDefault();
    this.setState({ isEditing: true });
  }

  dismissForm(type) {
    if(type === 'Editing') {
      this.setState({ isEditing: false });
    } else {
      this.props.triggerReplyBox(false, null);
    }
  }

  updateComment(form) {
    if(form.comment.raw_body !== this.props.comment.raw_body) {
      let id = this.props.comment.id
      this.props.updateComment({ comment: { id: id, raw_body: form.comment.raw_body } }, id);
    }
  }

  render() {
    const { avatarLink, body, raw_body, createdAt, deleted, depth, id, likingUsers, parent_id, user_id, userName, userLink } = this.props.comment;
    const { commentable } = this.props;
    let rootClass = depth === 0 ? 'comment' : 'comment comment-nested';
    let date = window ? window.moment(createdAt).fromNow() : createdAt;

    let deleteOrFlagButton = (user_id === this.props.currentUser.id || this.props.currentUser.isAdmin)
                           ? (<li>
                                <a href="javascript:void(0);" onClick={this.handleDeleteClick.bind(this, id)}>Delete</a>
                              </li>)
                           : (<li>
                                <FlagButton currentUserId={this.props.currentUser.id} flaggable={{ type: "Comment", id: id }}/>
                              </li>);

    let replyButton = this.props.parentIsDeleted === false
                ? (<li>
                    <a href="javascript:void(0);" onClick={this.handleReplyClick.bind(this, parent_id || id)}>{depth === 0 ? 'Reply' : 'Reply to conversation'}</a>
                    </li>)
                : (<li className="text-muted">(Discussion closed)</li>);

    let counter = likingUsers.length > 0
                ? (<li className="r-comments-counter"><i className="fa fa-thumbs-o-up"></i><span>{likingUsers.length}</span></li>)
                : (null);

    let trailingMiddot = counter ? (<li className="middot">•</li>) : (null);

    let editButton = (user_id === this.props.currentUser.id || this.props.currentUser.isAdmin)
             ? (<li>
                  <a href="javascript:void(0);" onClick={this.handleEditClick}>Edit</a>
                </li>)
             : (null);

    let actions = this.props.currentUser.id
                ? (<ul className="comment-actions">
                    <LikeButton commentId={id} currentUserId={this.props.currentUser.id} parentId={parent_id} likingUsers={likingUsers} deleteLike={this.props.deleteLike} postLike={this.props.postLike} />
                    <li className="middot">•</li>
                    {replyButton}
                    {trailingMiddot}
                    {counter}
                  </ul>)
                : likingUsers.length > 0
                ? (<ul className="comment-actions">
                    {counter}
                  </ul>)
                : (null);

    let replyBox = (this.props.replyBox.show && this.props.replyBox.id === id)
                 ? (<div className="reply-box">
                      <div className="reply-box-center-line">
                      </div>
                      <CommentForm commentable={commentable}
                                   commentId={id}
                                   dismiss={this.dismissForm.bind(this, 'Reply')}
                                   dismissable={true}
                                   formData={this.props.formData}
                                   isReply={(parent_id !== null) || (parent_id === null && this.props.children.length > 0)}
                                   onPost={this.handlePost}
                                   parentId={parent_id || id}
                                   placeholder={this.props.placeholder} />
                    </div>)
                 : (null);

    let avatar = userLink
                ? (<a href={userLink}>
                    <img src={avatarLink} alt={userName} />
                  </a>)
                : (<img src={avatarLink} alt={userName} />);

    let name = userLink
              ? (<a href={userLink}>{userName}</a>)
              : userName;

    let manageDropdown = (<div className="dropdown comment-manage pull-right">
                          <a className="dropdown-toggle btn btn-link btn-sm" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true" href="javascript:void(0)">
                            <i className="fa fa-ellipsis-v" />
                          </a>
                          <ul className="dropdown-menu">
                            {editButton}
                            {deleteOrFlagButton}
                          </ul>
                        </div>);

    let comment = depth === 0 && deleted === true
                ? (<div>
                    <div className={rootClass} id={id}>
                      <div className="comment-title">
                        <div className="avatar">{avatar}</div>
                        <div className="profile-name">
                          <h4>
                            <strong>{name}</strong>
                          </h4>
                          <span className="text-muted comment-date">{date}</span>
                        </div>
                        {manageDropdown}
                      </div>
                      <div className="comment-body">
                        This comment has been deleted.
                      </div>
                    </div>
                    {this.props.children}
                  </div>)
                : (<div>
                    <div className={rootClass} id={id}>
                      <div className="comment-title">
                        <div className="avatar">{avatar}</div>
                        <div className="profile-name">
                          <h4>
                            <strong>{name}</strong>
                          </h4>
                          <span className="text-muted comment-date">{date}</span>
                        </div>
                        {manageDropdown}
                      </div>
                      <div className="comment-body" dangerouslySetInnerHTML={{ __html: markdown.render(raw_body) }}></div>
                      {actions}
                    </div>
                    {this.props.children}
                    {replyBox}
                  </div>);

    let editForm = (<div>
                      <div className={rootClass} id={id}>
                        <div className="comment-title">
                          <div className="avatar">{avatar}</div>
                          <div className="profile-name">
                            <h4>
                              <strong>{name}</strong>
                            </h4>
                            <span className="text-muted comment-date">{date}</span>
                          </div>
                        </div>
                        <CommentForm commentable={commentable}
                                     commentId={id}
                                     dismiss={this.dismissForm.bind(this, 'Editing')}
                                     dismissable={true}
                                     formData={this.props.formData}
                                     isEditing={true}
                                     isReply={parent_id !== null}
                                     onPost={this.updateComment}
                                     parentId={parent_id || id}
                                     placeholder={this.props.placeholder}
                                     rawBody={raw_body} />
                      </div>
                      {this.props.children}
                    </div>);

    let editableComment = this.state.isEditing ? (editForm) : (comment);

    return (editableComment);
  }
}

Comment.PropTypes = {
  comment: PropTypes.object.isRequired,
  commentable: PropTypes.object.isRequired,
  commentUpdated: PropTypes.object.isRequired,
  children: PropTypes.array,
  currentUser: PropTypes.object.isRequired,
  deleteComment: PropTypes.func.isRequired,
  deleteLike: PropTypes.func.isRequired,
  formData: PropTypes.object.isRequired,
  handlePost: PropTypes.func.isRequired,
  parentIsDeleted: PropTypes.bool.isRequired,
  placeholder: PropTypes.string,
  postComment: PropTypes.func.isRequired,
  postLike: PropTypes.func.isRequired,
  replyBox: PropTypes.object.isRequired,
  scrollTo: PropTypes.object.isRequired,
  toggleScrollTo: PropTypes.func.isRequired,
  triggerReplyBox: PropTypes.func.isRequired,
  updateComment: PropTypes.func.isRequired
};