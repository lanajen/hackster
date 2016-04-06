import React, { Component } from 'react'
import { Route, IndexRoute } from 'react-router'
import Vendors from './components/Vendors'

import App from './app'



export default (
  <Route path='/' component={App}>
    <Route path='#vendors' component={Vendors}/>
  </Route>
)


