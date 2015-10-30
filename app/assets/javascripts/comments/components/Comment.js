import React, { Component, PropTypes } from 'react';
import CommentForm from './CommentForm';
import FlagButton from '../../flag_button/app';

export default class Comment extends Component {
  constructor(props) {
    super(props);
    this.handleDeleteClick = this.handleDeleteClick.bind(this);
  }

  handleDeleteClick(commentId, e) {
    if(window) {
      let confirm = window.confirm('Are you sure you want to delete this comment?');
      if(confirm) {

      } else {
        return;
      }
    }
  }

  render() {
    const { avatarLink, body, canDestroy, createdAt, depth, id, user_id, userName, userSignedIn } = this.props.comment;
    let rootClass = depth === 0 ? 'comment' : 'comment comment-nested';
    let deleteOrFlagButton = canDestroy
                           ? (<li className="default-hidden">
                                <a href="javascript:void(0);" onClick={this.handleDeleteClick.bind(this, id)}>Delete</a>
                              </li>)
                           : (<li className="default-hidden">
                                <FlagButton currentUserId={user_id} flaggable={{ type: "Comment", id: id }}/>
                              </li>);
    let actions = userSignedIn
                ? (<ul className="comment-actions">
                    <li>
                      <a href="javascript:void(0);">{depth === 0 ? 'Reply' : 'Reply to conversation'}</a>
                    </li>
                    {deleteOrFlagButton}
                  </ul>)
                : (null);
    // Bring the replyBox up, focus it and scroll to it.


    return (
      <div className={rootClass}>
        <div className="comment-title">
          <div className="avatar" dangerouslySetInnerHTML={{__html: avatarLink}}></div>
          <div className="profile-name">
            <h4>
              <strong dangerouslySetInnerHTML={{__html: userName}}></strong>
            </h4>
            <span className="text-muted comment-date">{createdAt + " ago"}</span>
          </div>
        </div>
        <div className="comment-body" dangerouslySetInnerHTML={{__html: body}}></div>
        {actions}
        {this.props.children}
      </div>
    );
  }
}

Comment.PropTypes = {
  comment: React.PropTypes.object,
  children: React.PropTypes.array
};