import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { Link } from 'react-router';

import Vendors from '../components/Vendors';
import Hero from '../components/Hero'

import * as AuthActions from '../actions/auth';

class Vendor extends Component {
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
    const { params, user } = this.props;

    return (
      <div>
        <Hero user={user}/>
        <Vendors/>
      </div>
    );
  }
}

Vendor.PropTypes = {

};

function mapStateToProps(state) {
  return {
    auth: state.auth,
    user: state.user
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(AuthActions, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Vendor);