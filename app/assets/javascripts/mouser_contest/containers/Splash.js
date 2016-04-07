import React, { Component } from 'react';
import { Link } from 'react-router'
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as AuthActions from '../actions/auth';

class Splash extends Component {
  constructor(props) {
    super(props);

    this.props.actions.authorizeUser(true);
  }

  render() {
    console.log("Splash: is authorized?", this.props.auth.authorized);
    const conditional = this.props.auth.authorized
      ? (<div id='#mouser-contest'>
          <Link to="/vendor/particle">Route to vendors</Link>
          <br/>
          <a href="/vendor/particle">Rails route to vendors</a>
          {this.props.children}
        </div>)
      : null;

    return conditional;
  }
}

function mapStateToProps(state) {
  return {
    auth: state.auth
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(AuthActions, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Splash);