import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as AuthActions from '../actions/auth';
import Footer from '../components/Footer';

class Root extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { location, user } = this.props;
    const isAdminPath = location.pathname && location.pathname !== '/admin';
    return (
      <div id="mousercontest-landing">
        { this.props.children }
        { isAdminPath ? <Footer /> : null }
      </div>
    );
  }
}

Root.PropTypes = {
}

function mapStateToProps(state) {
  return {
    auth: state.auth,
    user: state.user
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(AuthActions, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Root);

