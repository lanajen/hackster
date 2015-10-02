import React from 'react';
import { SortFilters } from '../actions';

const SortFilter = React.createClass({
  getInitialState: function() {
    return {
      value: this.props.initialValue
    }
  },

  handleOnChange: function(e){
    this.setState({ value: e.target.value });
    this.props.onFilterChange(e.target.value);
  },

  render: function() {
    return (
      <div className="sort-filter input-group">
        <span className='input-group-addon'><i className="fa fa-sort"></i></span>
        <select className="form-control" ref='select' value={this.state.value} onChange={this.handleOnChange}>
          <option value={SortFilters.ALPHABETICAL}>Alphabetically</option>
          <option value={SortFilters.MOST_USED}>Most used</option>
          <option value={SortFilters.MOST_FOLLOWED}>Most owned</option>
        </select>
      </div>
    );
  },
});

export default SortFilter;