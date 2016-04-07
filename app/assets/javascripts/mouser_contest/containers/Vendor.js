import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as AuthActions from '../actions/auth';

class Vendor extends Component {
  constructor(props) {
    super(props);
  }

  componentDidUpdate(prevProps, prevState) {
    // if(this.props.auth.authorized && !this.state.render) {
    //   const mount = document.getElementById('vendor');
    //   if(mount) {
    //     mount.parentNode.removeChild(mount);
    //     this.setState({ render: true });
    //   }
    // }
  }

  componentDidMount() {
    if(!this.props.auth.authorized) {
      window.location = '/';
    }
  }

  render() {
    console.log("Vendor is authorized?", this.props.auth.authorized);
    const view = this.props.auth.authorized
      ? (<div>
          Vendor Component
          {this.props.children}
        </div>)
      : null;

    return view;
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