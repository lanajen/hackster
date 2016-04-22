import React, { PropTypes } from 'react';
import { Router, Route, IndexRoute, browserHistory } from 'react-router';
import { Provider } from 'react-redux';
import { syncHistoryWithStore } from 'react-router-redux'
import createBrowserHistory from 'history/lib/createBrowserHistory'


import Root from './containers/Root';
import Splash from './containers/Splash';
import Vendor from './containers/Vendor';
import Admin from './containers/Admin';

import configureStore from './configStore';

import { setInitialData } from './actions/contest';
import { setUserAsAdmin } from './actions/user';  // Move this to setInitialData.

const store = configureStore();
const history = syncHistoryWithStore(browserHistory, store);

const MouserContest = (props) => {
  store.dispatch(setInitialData(props));

  // Really, we can just set the user model and delimit what we need in the controller before hand.  If they're an admin then
  // its they are already flagged, just set the user normally.
  store.dispatch(setUserAsAdmin(true));

  return (
    <Provider store={store}>
      <Router history={history}>
        <Route path='/' component={Root}>
          <IndexRoute component={Splash} />
          <Route path='admin' component={Admin} />
          <Route path=':vendor' component={Vendor} />
        </Route>
      </Router>
    </Provider>
  );
}

MouserContest.PropTypes = {

}

export default MouserContest;