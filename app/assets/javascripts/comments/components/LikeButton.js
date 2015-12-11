import React, { Component, PropTypes } from 'react';

export default class LikeButton extends Component {
  constructor(props) {
    super(props);
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick(content) {
    content === 'Like' ? this.props.postLike(this.props.commentId, this.props.parentId)
                       : this.props.deleteLike(this.props.commentId, this.props.parentId);
  }

  render() {
    let { likingUsers, currentUserId } = this.props;
    let content = likingUsers.indexOf(currentUserId) >= 0 ? 'Liked' : 'Like';

    return (
      <li className="r-comment-like-button">
        <a href="javascript:void(0);" onClick={this.handleClick.bind(this, content)}>{content}</a>
      </li>
    );
  }
}

LikeButton.PropTypes = {
  commentId: PropTypes.number.isRequired,
  currentUserId: PropTypes.number.isRequired,
  deleteLike: PropTypes.func.isRequired,
  likingUsers: PropTypes.array.isRequired,
  parentId: PropTypes.number.isRequired,
  postLike: PropTypes.func.isRequired,
};