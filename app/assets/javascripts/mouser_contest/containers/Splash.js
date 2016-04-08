import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as AuthActions from '../actions/auth';

class Splash extends Component {
  constructor(props) {
    super(props);
  }

  // React router and connect will complain if we move this up into the constructor.
  componentWillMount() {
    if(!this.props.auth.authorized) {
      this.props.actions.authorizeUser(true);
    }
  }

  render() {
    return (
      <div>
        Splash Page
        {this.props.children}
      </div>
    );
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