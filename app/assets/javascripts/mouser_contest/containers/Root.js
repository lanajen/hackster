import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as AuthActions from '../actions/auth';
import Toolbar from '../components/Toolbar';

class Root extends Component {
  constructor(props) {
    super(props);
  }

  // Toolbar
  // Children / Body
  // Footer
  render() {
    return (
      <div>
        <Toolbar />
        {this.props.children}
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

