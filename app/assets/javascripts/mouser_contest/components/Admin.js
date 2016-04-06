import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';

// Project Name: Link,
// Author: Text,
// Sumbission State: Text
// Submission date: Date,
// Vendor: Text
//
//

const projects = [
  { projectName: 'P1', author: 'david bowie', submissionState: '' }
];

export default class Admin extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    const title = 'Admin Page';

    // Title
    // Timeline / Progress slider (input type of range)
    // - has confirm button with a follow up prompt that submits contest changes
    // Dynamic display per timeline.
    return (
      <div>
         {title}
      </div>
    );
  }
}

Admin.PropTypes = {

};