import React from 'react';
import ReactDOM from 'react-dom';

const SearchBox = React.createClass({
  componentWillMount: function() {
     this.handleOnKeyUp = _.debounce(this.handleOnKeyUp, 250);
  },

  handleOnKeyUp: function(e) {
    let value = ReactDOM.findDOMNode(this.refs.search).value;
    this.props.onSearch(value);
  },

  render: function() {
    return (
      <div className="search-box input-group">
        <span className='input-group-addon'><i className="fa fa-search"></i></span>
        <input className="form-control" type="text" ref="search" placeholder="Search..." onKeyUp={this.handleOnKeyUp} />
      </div>
    );
  },
});

export default SearchBox;