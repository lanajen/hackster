import React from 'react';
import injectTapEventPlugin from 'react-tap-event-plugin';
import FollowButton from './components/FollowButton';
import FollowersStore from './stores/FollowersStore';

injectTapEventPlugin();

const App = React.createClass({

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
        csrfToken = _.find(metaList, {name: 'csrf-token'}).content;

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