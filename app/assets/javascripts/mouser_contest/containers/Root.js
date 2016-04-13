import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as AuthActions from '../actions/auth';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';

class Root extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div id="mousercontest-landing">
        <Navbar />
        {this.props.children}
        <Footer />
      </div>
    );
  }
}

Root.PropTypes = {

};

function mapStateToProps(state) {
  return {
    auth: state.auth
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(AuthActions, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Root);

