import React, { Component, PropTypes } from 'react';

export default class Vendor extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div>
        Vendors
        {this.props.children}
      </div>
    );
  }
}

Vendor.PropTypes = {

};