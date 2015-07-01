import React from 'react';
import { FlatButton } from 'material-ui';

const FollowButton = React.createClass({

  render: function() {
    console.log('FB props', this.props);
    return (
      <div>
        <FlatButton label="Follow" />
      </div>
    );
  }

});

export default FollowButton;