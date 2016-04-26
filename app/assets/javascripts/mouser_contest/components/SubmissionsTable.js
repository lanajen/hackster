import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';

import TableRow from './TableRow';

const SubmissionsTable = props => {

  function getValue(obj, property) {
    return ['author', 'project'].indexOf(property) !== -1 ? obj[property]['name'] : obj[property];
  }

  function limitingFilter(list, filters, filterKey) {
    return list.filter(item => {
      return item[filterKey] === filters[filterKey] || filters[filterKey] === 'default' || filters[filterKey] === 'new';
    });
  }

  function sortingFilter(list, property, direction) {
    if(direction === 'default') return list;

    return list.sort((a, b) => {
      if(direction === 'ascending' || direction === 'oldest') {
        if(getValue(a, property) < getValue(b, property)) return -1;
        if(getValue(a, property) > getValue(b, property)) return 1;
        return 0;
      } else {
        if(getValue(a, property) > getValue(b, property)) return -1;
        if(getValue(a, property) < getValue(b, property)) return 1;
        return 0;
      }
    });
  }

  function filterSubmissions(submissions, filters) {
    const filterKeys = Object.keys(filters);

    if(!filterKeys.length) return submissions;

    let subs = submissions;

    filterKeys.forEach(filter => {
      switch(filter) {
        case 'vendor':
        case 'status':
          subs = limitingFilter(subs, filters, filter);
          break;

        case 'project':
        case 'author':
        case 'date':
          subs = sortingFilter(subs, filter, filters[filter]);
          break;

        default:
          break;
      };
    });

    return subs;
  }

  const { submissions, filters } = props;

  const rows = filterSubmissions(submissions, filters)
    .map((submission, index, list) => {
      return <TableRow key={index}
                       firstRow={index === 0}
                       lastRow={index === list.length-1}
                       position={index}
                       rowData={{ ...submission, buttons: true }}
                       isFetching={props.isFetching}
                       onActionClick={props.onActionClick} />
    });

  return (
    <div style={{ display: 'flex', flexDirection: 'column' }}>
      <TableRow rowData={{ vendor: 'Vendor', project: 'Project', author: 'Author', date: 'Submission Date', buttons: false }} header={true} />
      {rows}
    </div>
  );
}

SubmissionsTable.PropTypes = {
  filters: PropTypes.object.isRequired,
  isFetching: PropTypes.object,
  onActionClick: PropTypes.func.isRequired,
  submissions: PropTypes.array.isRequired
}

export default SubmissionsTable;