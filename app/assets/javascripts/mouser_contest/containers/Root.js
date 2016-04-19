import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as AuthActions from '../actions/auth';
import * as ContestActions from '../actions/contest';

import Messenger from '../components/Messenger';
import Footer from '../components/Footer';

class Root extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { contest, location, user } = this.props;
    const isAdminPath = location.pathname && location.pathname !== '/admin';
    return (
      <div id="mousercontest-landing">
        { this.props.children }
        { isAdminPath ? <Footer /> : null }
        { contest.messenger.open ? <Messenger messenger={contest.messenger} dismiss={this.props.actions.toggleMessenger} /> : null }
      </div>
    );
  }
}

Root.PropTypes = {
}

function mapStateToProps(state) {
  return {
    auth: state.auth,
    contest: state.contest,
    user: state.user
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators({...AuthActions, ...ContestActions}, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Root);

