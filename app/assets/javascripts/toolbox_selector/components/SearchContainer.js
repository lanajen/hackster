import React from 'react';
import SearchBox from './SearchBox';
import SortFilter from './SortFilter';

const SearchContainer = React.createClass({
  render: function() {

    return (
      <div className="search-container">
        <SearchBox />
        <SortFilter filter={this.props.filter} />
      </div>
    );
  },
});

export default SearchContainer;