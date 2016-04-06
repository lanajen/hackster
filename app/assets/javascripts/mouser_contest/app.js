import React, { Component } from 'react';
import { browserHistory, Link } from 'react-router'


export default class MouserContest extends Component {


  constructor(props) {
    super(props);
  }

  render() {
    console.log(window.location)
    return (
      <div id='#mouser-contest'>
        <a> <Link to={'/vendors'}>Route to Vendors</Link></a>
        <br/>
        <a> <Link to={'/matches'}>Route to Matches</Link></a>
        <section>hi</section>
      </div>
    )
  }
}

