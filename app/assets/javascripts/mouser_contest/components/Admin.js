import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';

import SubmissionsTable from './SubmissionsTable';

// Project Name: Link,
// Author: Text,
// Sumbission State: Text
// Submission date: Date,
// Vendor: Text

function makeProjects(amount) {
  amount = amount || 5;
  const vendors = [ 'Arduino', 'Intel', 'Microsoft', 'SparkFun', 'C.H.I.P' ];
  const authors = [ 'Duder', 'Satan', 'Bowie', 'IndiaGuy', 'OtherDuder' ];
  const projects = [ 'Blinky lights', 'Water gun', 'Moar lights', 'VR porn', 'Drugs' ];

  function random(arr) {
    return arr[Math.floor(Math.random() * arr.length)];
  }

  return Array.from(new Array(amount), () => {
    return {
      vendor: random(vendors),
      project: random(projects),
      author: random(authors),
      subDate: new Date().toString()
    };
  });
}

export default class Admin extends Component {
  constructor(props) {
    super(props);

    this.state = { filters: {} };
  }

  render() {
    const subs = makeProjects(30);
    const title = 'Admin Page';
    // Title
    // Timeline / Progress slider (input type of range)
    // - has confirm button with a follow up prompt that submits contest changes
    // Dynamic display per timeline.
    //
    // Filters panel
    // Table
    const vendorOpts = subs.reduce((acc, sub) => {
      if(acc.indexOf(sub.vendor) === -1) {
        acc.push(sub.vendor);
      }
      return acc;
    }, [])
    .map((sub, index) => {
      return <option value={sub}>{sub}</option>
    });


    return (
      <div>
        {title}
        <div>
          <div style={{ textAlign: 'center'}}>Timeline</div>
          <input type="range" />
        </div>
        <div>
          <select name="" id="" onChange={(e) => this.setState({ filters: { vendor: e.target.value }})}>
            {React.Children.toArray(vendorOpts)}
          </select>
        </div>
        <SubmissionsTable submissions={subs} filters={this.state.filters} />
      </div>
    );
  }
}

Admin.PropTypes = {

};