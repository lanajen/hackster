import React from 'react';

var NotificationDropdown = React.createClass({

  render: function() {
    let notifications = this.props.notifications.map((note, index) => {
      if (note.message) {
        let classNames = ['notification-item'];
        if (!note.read) classNames.push('notification-unread');
        classNames = classNames.join(' ');

        return (
          <li key={index} className={classNames}>
            <p className="notification" dangerouslySetInnerHTML={{__html: note.message}}></p>
            <p className="notification-time">{note.time}</p>
          </li>
        );
      }
    }).filter((item) => item !== undefined );

    if(!notifications.length) {
      notifications = (<p className="notification-item">Notifications about other members' activity related to you will appear here.</p>);
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