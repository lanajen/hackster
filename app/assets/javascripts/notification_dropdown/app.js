import React from 'react';
import NotificationDropdown from './components/NotificationDropdown';
import { fetchNotifications } from '../utils/ReactAPIUtils';

const App = React.createClass({

  getInitialState() {
    return {
      csrfToken: null,
      notifications: [],
      showDropdown: false,
      isLoading: false
    };
  },

  componentWillMount() {
    if(this.state.csrfToken === null) {
      let metaList, csrfToken, following;

      if(document) {
        metaList = document.getElementsByTagName('meta');
        csrfToken = _.findWhere(metaList, {name: 'csrf-token'}).content;

        this.setState({
          csrfToken: csrfToken
        });
      }
    }
  },

  componentDidMount() {
    // Activates the tooltip.
    if(window) {
      window.$('[data-toggle="tooltip"]').tooltip();
    }
  },

  componentWillUnmount() {
    // Cleans up any listeners.
    if(window) {
      window.$('[data-toggle="tooltip"]').tooltip('destroy');
    }
  },

  onNotificationButtonClick() {
    if(this.state.csrfToken) {
      // Bootstrap sets a class of open to this DOM node.  We only want make a request if the class is 'open' to prevent another call if
      // the button is clicked to close the dropdown.  React_component doesn't allow refs, so we set one here and look up the parent node.
      let isDropdownOpen = React.findDOMNode(this.refs.dropdown).parentNode.className.split(' ').indexOf('open') > 0;

      if(isDropdownOpen) {
        let promise = fetchNotifications(this.state.csrfToken);
        this.setState({
          isLoading: true
        });

        promise.then(function(response) {
          let notifications = response.body.notifications;

          this.setState({
            isLoading: false,
            notifications: notifications
          });
        }.bind(this)).catch(function(err) { console.log('Request Error: ' + err); });
      }
    }
  },

  render: function() {
    let icon = this.props.hasNotifications ? (<i className="fa fa-bell-o text-danger"></i>) :
                                             (<i className="fa fa-bell-o"></i>);
    let toolTipTitle = this.props.hasNotifications ? 'You have unread notifications' : 'No new notifications';

    return (
      <div className="dropdown">
        <span className="notification-button-wrapper dropdown-toggle" ref="dropdown" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" onClick={this.onNotificationButtonClick}>
          <a href="javascript:void(0)" className="notification-button" rel="tooltip" title={toolTipTitle} data-toggle="tooltip" data-placement='bottom' data-container='body'>
            {icon}
          </a>
        </span>

        <div ref="notifications" className="dropdown-menu notification-dropdown">
          <NotificationDropdown notifications={this.state.notifications} isLoading={this.state.isLoading} {...this.props} />
        </div>
      </div>
    );
  }

});

export default App;