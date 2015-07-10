import React from 'react';
import _ from 'lodash';

var NotificationDropdown = React.createClass({

  render: function() {
    let notifications = _.map(this.props.notifications, function(note, index) {
      let bgColor = index % 2 === 0 ? 'white' : '#F8F8F8';
      return (
        <li key={index} className="notification-item" style={{backgroundColor: bgColor}}>
          <p className="notification" dangerouslySetInnerHTML={{__html: note.message}}></p>
          <p className="notification-time">{note.time}</p>
        </li>
      );
    });

    if(!notifications.length) {
      notifications = (<p className="notification-item" style={{backgroundColor: '#F8F8F8'}}>Notifications about other makers' activity related to you will appear here.</p>);
    }

    return (
      <div className="notification-list-wrapper">
        <ul className="list-group notification-list">
          {notifications}
        </ul>
        <div className="notification-footer">
          <a href={this.props.path}>View More</a>
        </div>
      </div>
    );
  }

});

export default NotificationDropdown;