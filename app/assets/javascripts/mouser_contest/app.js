import React, { Component} from 'react';
import { Router, Route, browserHistory } from 'react-router';
import { Provider } from 'react-redux';
import { syncHistoryWithStore } from 'react-router-redux'

import Splash from './containers/Splash';
// import Vendors from './containers/Vendors';
// import Match from './containers/Match';

import configureStore from './configStore';

const store = configureStore();
const history = syncHistoryWithStore(browserHistory, store);

const MouserContest = () => (
  <Provider store={store}>
    <Router history={history}>
      <Route path='/' component={Splash}/>
      {/* <Route path='vendor' component={Vendors}/> */}
    </Router>
  </Provider>
)

export default MouserContest;
