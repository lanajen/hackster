import React from 'react';
import { SortFilters } from '../actions';

const SortFilter = React.createClass({
  render: function() {
    console.log('FILTER', this.props.filter);

    return (
      <div className="sort-filter">
        <span>Sort by:</span>
        <select ref='select'>
          <option value={SortFilters.ALPHABETICAL} selected={this.props.filter == 'ALPHABETICAL'}>Alphabetically</option>
          <option value={SortFilters.MOST_USED} selected={this.props.filter == 'MOST_USED'}>Most used</option>
          <option value={SortFilters.MOST_FOLLOWED} selected={this.props.filter == 'MOST_FOLLOWED'}>Most owned</option>
        </select>
      </div>
    );
  },
});

export default SortFilter;