import React, { Component } from 'react'
import { Router, Route, IndexRoute } from 'react-router'

import App from './app'
import Vendors from './components/Vendors';

export default function renderRoutes() {
  return (
    <Router history={history}>
      <Route path='/' component={App}>
        <Route path='vendors' component={Vendors}/>
      </Route>
    </Router>
  );
}


