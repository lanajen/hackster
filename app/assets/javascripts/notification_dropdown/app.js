import React from 'react';
import NotificationDropdown from './components/NotificationDropdown';
import { fetchNotifications } from '../utils/ReactAPIUtils';

const App = React.createClass({

  getInitialState() {
    return {
      csrfToken: null,
      notifications: []
    };
  },

  componentWillMount() {
    if(this.state.csrfToken === null) {
      let metaList, csrfToken, following;

      if(document) {
        metaList = document.getElementsByTagName('meta');
        csrfToken = _.findWhere(metaList, {name: 'csrf-token'}).content;

        let promise = fetchNotifications(csrfToken);

        promise.then(function(response) {
          let notifications = response.body.notifications;

          this.setState({
            csrfToken: csrfToken,
            notifications: notifications
          });
        }.bind(this)).catch(function(err) { console.log('Request Error: ' + err); });

      }
    }
  },

  render: function() {
    return (
      <NotificationDropdown notifications={this.state.notifications} {...this.props} />
    );
  }

});

export default App;