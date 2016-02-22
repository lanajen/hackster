import React from 'react';

const User = React.createClass({
  render: function() {
    const { userName, userSlug, avatarLink, user_id, userRole } = this.props;

    if (!user_id || user_id === 0)
      return (<span />);

    let role;
    if (['admin', 'hackster_moderator'].indexOf(userRole) > -1) {
      role = ' (Hackster team)';
    } else if (['super_moderator'].indexOf(userRole) > -1) {
      role = ' (super community moderator)';
    } else if (['moderator'].indexOf(userRole) > -1) {
      role = ' (community moderator)';
    }

    return (
      <span className='user-name'>
        <img className="img-circle" src={avatarLink} />
        <a href={`/${userSlug}`} target='_blank'>{userName}</a>
        {role}
        <span> </span>
      </span>
    );
  }
});

export default User;