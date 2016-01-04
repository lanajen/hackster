import React from 'react';

const User = React.createClass({
  render: function() {
    return (
      <span className='user-name'>
        {this.renderImg()}
        {this.renderName()}
      </span>
    );
  },

  renderImg: function() {
    const { avatarLink } = this.props;

    if (!avatarLink) return;

    return (<img className="img-circle" src={avatarLink} />);
  },

  renderName: function() {
    const { userName, userSlug } = this.props;

    if (!userName || !userSlug) return;

    return (<a href={`/${userSlug}`} target='_blank'>{userName}</a>);
  }
});

export default User;