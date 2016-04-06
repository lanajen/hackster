import React, { Component} from 'react'
import { Router, Route, IndexRoute, browserHistory } from 'react-router'

import App from './app'
import Vendors from './components/Vendors'

import { Provider } from 'react-redux'
import { store, history } from './store.js'


const MouserContestMount = () => (
  <Provider store={store}>
    <Router history={history}>
      <Route path='/' component={App}/>
      <Route path='/vendors' component={Vendors}/>
    </Router>
  </Provider>
)

export default MouserContestMount;
