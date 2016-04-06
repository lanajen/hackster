import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';

import TableRow from './TableRow';

export default class SubmissionsTable extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { submissions, filters } = this.props;
    // Filters for approved, rejected, undecided, all

    const rows = submissions.filter(submission => {
      if(Object.keys(filters).length) {
        return filters.vendor === submission.vendor;
      } else {
        return true;
      }
    }).map((submission, index) => {
      return <TableRow key={index} rowData={{ buttons: true, ...submission }} />
    });

    return (
      <div style={{ display: 'flex', flexDirection: 'column' }}>
        <TableRow rowData={{ vendor: 'Vendor', project: 'Project', author: 'Author', subDate: 'Submission Date', buttons: false }} />
        {rows}
      </div>
    );
  }
}

SubmissionsTable.PropTypes = {
  filters: PropTypes.object.isRequired,
  submissions: PropTypes.array.isRequired
};