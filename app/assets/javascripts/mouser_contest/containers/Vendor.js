import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { Link } from 'react-router'

import * as AuthActions from '../actions/auth';

class Vendor extends Component {
  constructor(props) {
    super(props);

    if(!props.auth.authorized) {
      this.props.actions.authorizeUser(true);
    }
  }

  render() {
    const { params } = this.props;

    return (
      <div>
        {`${params.vendor} Component`}
        {this.props.children}
      </div>
    );
  }
}

Vendor.PropTypes = {

};

function mapStateToProps(state) {
  return {
    auth: state.auth
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(AuthActions, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Vendor);