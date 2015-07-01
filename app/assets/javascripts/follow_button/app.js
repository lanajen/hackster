import React from 'react';
import FluxComponent from 'flummox/component';
import Flux from './flux';
import injectTapEventPlugin from 'react-tap-event-plugin';
import FollowButton from './components/FollowButton';
const ThemeManager = require('material-ui/lib/styles/theme-manager')();

const flux = new Flux();
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
      <FluxComponent flux={flux} connectToStores={['followButton']}>
        <FollowButton {...this.props}/>
      </FluxComponent>
    );
  }
});

export default App;