import React, { Component, PropTypes } from 'react';
import { Router, Route, browserHistory } from 'react-router';
import { Provider } from 'react-redux';
import { syncHistoryWithStore } from 'react-router-redux'

import Splash from './containers/Splash';
import Vendor from './containers/Vendor';

import configureStore from './configStore';

const store = configureStore();
const history = syncHistoryWithStore(browserHistory, store);

// const MouserContest = () => {

//   return (
//     <Provider store={store}>
//       <Router history={history}>
//         <Route path='/' component={Splash}/>
//         <Route path='vendor' component={Vendor}/>
//       </Router>
//     </Provider>
//   );
// }

// export default MouserContest;
function requireAuth(nextState, replace) {
  if (false) {
    console.log("redirecting!");
    replace({
      pathname: '/',
      state: { nextPathname: nextState.location.pathname }
    })
  }
}

export default class MouserContest extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <Provider store={store}>
        <Router history={history}>
          <Route path='/' component={Splash}/>
          <Route path='vendor/:user_name' component={Vendor} onEnter={requireAuth}/>
        </Router>
      </Provider>
    );
  }
}

MouserContest.PropTypes = {

};