import React from 'react';

const User = React.createClass({
  render: function() {
    const { user_id, avatarLink, userName, userSlug } = this.props;

    if (user_id == 0) return;

    return (
      <span className='user-name'>
        <img className="img-circle" src={avatarLink} />
        <a href={`/${userSlug}`} target='_blank'>{userName}</a>
      </span>
    );
  }
});

export default User;