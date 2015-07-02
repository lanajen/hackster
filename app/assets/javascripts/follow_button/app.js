import React from 'react';
import injectTapEventPlugin from 'react-tap-event-plugin';
import FollowButton from './components/FollowButton';
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

  render() {
    return (
      <FollowButton {...this.props}/>
    );
  }
});

export default App;