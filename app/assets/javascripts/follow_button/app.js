import React from 'react';
import injectTapEventPlugin from 'react-tap-event-plugin';
import FollowButton from './components/FollowButton';
import FollowersStore from './stores/FollowersStore';
const ThemeManager = require('material-ui/lib/styles/theme-manager')();
injectTapEventPlugin();

const App = React.createClass({

  childContextTypes: {
    muiTheme: React.PropTypes.object
  },

  getChildContext: function() {
    return {
      muiTheme: ThemeManager.getCurrentTheme()
    };
  },

  getInitialState() {
    return {
      csrfToken: null
    };
  },

  componentWillMount() {
    if(this.state.csrfToken === null) {
      let metaList, csrfToken, following;

      if(document) {
        metaList = document.getElementsByTagName('meta');
        csrfToken = _.findWhere(metaList, {name: 'csrf-token'}).content;

        this.setState({csrfToken: csrfToken});

        if(FollowersStore.isFetching === false) {
          FollowersStore.populateStore(csrfToken);
        }
      }
    }
  },

  render() {
    return (
      <FollowButton csrfToken={this.state.csrfToken} {...this.props}/>
    );
  }
});

export default App;