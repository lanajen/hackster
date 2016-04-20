import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as ContestActions from '../actions/contest';

import Messenger from '../components/Messenger';
import Footer from '../components/Footer';

class Root extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { contest, location, user } = this.props;
    return (
      <div id="mousercontest-landing">
        { this.props.children }
        { location.pathname && location.pathname === '/admin' ? null : <Footer /> }
        { contest.messenger.open ? <Messenger messenger={contest.messenger} dismiss={this.props.actions.toggleMessenger} /> : null }
      </div>
    );
  }
}

Root.PropTypes = {
}

function mapStateToProps(state) {
  return {
    contest: state.contest,
    user: state.user
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(ContestActions, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Root);

