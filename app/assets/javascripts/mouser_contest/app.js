import React, { Component, PropTypes } from 'react';
import { Router, Route, IndexRoute, browserHistory } from 'react-router';
import { Provider } from 'react-redux';
import { syncHistoryWithStore } from 'react-router-redux'

import Root from './containers/Root';
import Splash from './containers/Splash';
import Vendor from './containers/Vendor';
import Admin from './containers/Admin';

import configureStore from './configStore';

const store = configureStore();
const history = syncHistoryWithStore(browserHistory, store);

const MouserContest = () => {
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

};

export default MouserContest;