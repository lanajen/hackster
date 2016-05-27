import React from 'react';
import injectTapEventPlugin from 'react-tap-event-plugin';
import FollowButton from './components/FollowButton';
import FollowersStore from './stores/FollowersStore';

injectTapEventPlugin();

const App = React.createClass({

  componentWillMount() {
    let following;

    if (FollowersStore.isFetching === false) {
      FollowersStore.populateStore();
    }
  },

  render() {
    return (
      <FollowButton {...this.props}/>
    );
  }
});

export default App;