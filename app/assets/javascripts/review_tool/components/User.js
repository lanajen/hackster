import React from 'react';

const User = React.createClass({
  render: function() {
    const { userName, userSlug, avatarLink, user_id, userRole } = this.props;

    let role = userRole == 'hackster' ? ' (Hackster team)' :
              (userRole == 'moderator' ? ' (community moderator)' : null);

    if (!user_id || user_id === 0)
      return (<span />);

    return (
      <span className='user-name'>
        <img className="img-circle" src={avatarLink} />
        <a href={`/${userSlug}`} target='_blank'>{userName}</a>
        {role}
      </span>
    );
  }
});

export default User;