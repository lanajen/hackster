import React, { Component, PropTypes } from 'react';
import CommentForm from './CommentForm';
import FlagButton from '../../flag_button/app';
import LikeButton from './LikeButton';
import smoothScroll from '../utils/SmoothScroll';

export default class Comment extends Component {
  constructor(props) {
    super(props);
    this.handleDeleteClick = this.handleDeleteClick.bind(this);
    this.handleReplyClick = this.handleReplyClick.bind(this);
    this.handlePost = this.handlePost.bind(this);
    this.handleEditClick = this.handleEditClick.bind(this);
  }

  componentDidMount() {
    if (this.props.scrollTo.scroll
      && this.props.scrollTo.element.id === this.props.comment.id
      && window) {
      smoothScroll((React.findDOMNode(this).getBoundingClientRect().top + window.pageYOffset) - (window.innerHeight / 2), 500, () => {
        this.props.toggleScrollTo(false, null);
      });
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
    this.props.postComment(comment, true);
  }

  handleEditClick(e) {
    e.preventDefault();

  }

  render() {
    const { avatarLink, body, commentable_id, commentable_type, createdAt, deleted, depth, id, likingUsers, parent_id, user_id, userName, userSlug } = this.props.comment;
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
                  <a href="javascript:void(0);" onClick={this.handleEditClick.bind(this, )}>Edit</a>
                </li>)
             : (null);

    let trailingMiddot2 = editButton ? (<li className="middot">•</li>) : (null);

    let actions = this.props.currentUser.id
                ? (<ul className="comment-actions">
                    <LikeButton commentId={id} currentUserId={this.props.currentUser.id} parentId={parent_id} likingUsers={likingUsers} deleteLike={this.props.deleteLike} postLike={this.props.postLike} />
                    <li className="middot">•</li>
                    {replyButton}
                    <li className="middot">•</li>
                    {counter}
                    {trailingMiddot}
                    {deleteOrFlagButton}
                    {trailingMiddot2}
                    {editButton}
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
                      <CommentForm commentable={{ id: commentable_id, type: commentable_type }}
                                   formData={this.props.formData}
                                   isReply={true}
                                   onPost={this.handlePost}
                                   parentId={parent_id || id}
                                   placeholder={this.props.placeholder} />
                    </div>)
                 : (null);

    let avatar = userSlug
                ? (<a href={`/${userSlug}`}>
                    <img src={avatarLink} alt={userName} />
                  </a>)
                : (<img src={avatarLink} alt={userName} />);

    let name = userSlug
              ? (<a href={`/${userSlug}`}>{userName}</a>)
              : userName;

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
                      </div>
                      <div className="comment-body" dangerouslySetInnerHTML={{ __html: body }}></div>
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
  deleteLike: PropTypes.func.isRequired,
  formData: PropTypes.object.isRequired,
  handlePost: PropTypes.func.isRequired,
  placeholder: PropTypes.string,
  postComment: PropTypes.func.isRequired,
  postLike: PropTypes.func.isRequired,
  replyBox: PropTypes.object.isRequired,
  scrollTo: PropTypes.object.isRequired,
  toggleScrollTo: PropTypes.func.isRequired,
  triggerReplyBox: PropTypes.func.isRequired
};