import React from 'react';
import ReactDOM from 'react-dom';
import NotificationDropdown from './components/NotificationDropdown';
import { fetchNotifications } from './utils/Requests';

const App = React.createClass({

  getInitialState() {
    return {
      notifications: [],
      showDropdown: false,
      isLoading: false,
      hasLoaded: false,
      hasNotifications: this.props.initialHasNotifications
    };
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
    // Bootstrap sets a class of open to this DOM node.  We only want make a request if the class is 'open' to prevent another call if
    // the button is clicked to close the dropdown.  React_component doesn't allow refs, so we set one here and look up the parent node.
    let isDropdownOpen = ReactDOM.findDOMNode(this.refs.notifications).offsetParent !== null;

    if (isDropdownOpen && !this.state.hasLoaded) {
      let promise = fetchNotifications();
      this.setState({
        isLoading: true,
        hasLoaded: true
      });

      promise.then(function(response) {
        let notifications = response.body.notifications;

        this.setState({
          isLoading: false,
          notifications: notifications,
          hasNotifications: false
        });
      }.bind(this)).catch(function(err) { console.log('Request Error: ' + err); });
    }
  },

  render: function() {
    let icon = this.state.hasNotifications ? (<i className="fa fa-bell-o text-danger"></i>) :
                                             (<i className="fa fa-bell-o"></i>);

    return (
      <div className="dropdown">
        <span className="notification-button-wrapper dropdown-toggle" ref="dropdown" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" onMouseOver={this.onNotificationButtonClick}>
          <a href="javascript:void(0)" className="notification-button">
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