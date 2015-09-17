import React from 'react';

const SearchBox = React.createClass({
  render: function() {

    return (
      <div className="search-box">
        <input type="text" ref="search" placeholder="Search..."/>
      </div>
    );
  },
});

export default SearchBox;