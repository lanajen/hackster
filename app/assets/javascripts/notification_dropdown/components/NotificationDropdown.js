import React from 'react';
import _ from 'lodash';

var NotificationDropdown = React.createClass({

  render: function() {
    let notifications = _.map(this.props.notifications, function(note, index) {
      if (note.message) {
        let bgColor = 'white';
        return (
          <li key={index} className="notification-item" style={{backgroundColor: bgColor}}>
            <p className="notification" dangerouslySetInnerHTML={{__html: note.message}}></p>
            <p className="notification-time">{note.time}</p>
          </li>
        );
      }
    }).filter(function(item) { return item !== undefined; });

    if(!notifications.length) {
      notifications = (<p className="notification-item" style={{backgroundColor: '#F8F8F8'}}>Notifications about other makers' activity related to you will appear here.</p>);
    }

    if(this.props.isLoading) {
      notifications = (<i className="fa fa-spinner fa-3x fa-spin notifications-loading-icon"></i>);
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