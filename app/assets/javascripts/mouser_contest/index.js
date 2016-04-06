import React, { Component} from 'react'
import { render } from 'react-dom'

import routes from './routes.js'
import { Router, browserHistory } from 'react-router'
import injectTapEventPlugin from 'react-tap-event-plugin'

import { Provider } from 'react-redux'
import { store, history } from './store.js'


const MouserContestMount = () => (
  <Provider store={store}>
    <Router history={history}>{routes}</Router>
  </Provider>
)

export default MouserContestMount;
