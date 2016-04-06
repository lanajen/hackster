import React, { Component} from 'react'
import { Router, browserHistory } from 'react-router'
import { Provider } from 'react-redux'

import routes from './routes.js'
import { store, history } from './store.js'



const MouserContestMount = () => (
  <Provider store={store}>
    <Router history={history}>{routes}</Router>
  </Provider>
)

export default MouserContestMount;
