import React, { Component } from 'react';
import { Link } from 'react-router'

export default class Splash extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div id='#mouser-contest'>
        <Link to="/vendors">Route to Vendors</Link>
        <br/>
        <Link to="/matches">Route to Matches</Link>
        {this.props.children}
      </div>
    )
  }
}