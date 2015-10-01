import React from 'react';
import SearchBox from './SearchBox';
import SortFilter from './SortFilter';

const SearchContainer = React.createClass({
  handleOnFilterChange: function(filter) {
    this.props.onFilterChange(filter);
  },

  handleOnSearch: function(q) {
    this.props.onSearch(q);
  },

  render: function() {
    return (
      <div className="search-container row">
        <div className="col-sm-6">
          <SearchBox onSearch={this.handleOnSearch} />
        </div>
        <div className="col-sm-6">
          <SortFilter initialValue={this.props.filter} onFilterChange={this.handleOnFilterChange} />
        </div>
      </div>
    );
  },
});

export default SearchContainer;