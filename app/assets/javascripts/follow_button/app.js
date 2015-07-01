import React from 'react';
// import FluxComponent from 'flummox/component';
// import Flux from './flux';
import injectTapEventPlugin from 'react-tap-event-plugin';
import FollowButton from './components/FollowButton';
const ThemeManager = require('material-ui/lib/styles/theme-manager')();

// const flux = new Flux();
injectTapEventPlugin();

const App = React.createClass({

  componentWillMount() {
    console.log('WILL mOUNT');
  },

  childContextTypes: {
    muiTheme: React.PropTypes.object
  },

  getChildContext: function() {
    return {
      muiTheme: ThemeManager.getCurrentTheme()
    };
  },

  render() {
    console.log('PARENT RENDERED!');
    return (
      <FollowButton {...this.props}/>
    );
  }
});

export default App;