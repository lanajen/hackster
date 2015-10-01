import React from 'react';
import PartItem from './PartItem';

const PartsContainer = React.createClass({
  handleItemClick: function(id) {
    this.props.handlePartClick(id);
  },

  handlePrevClick: function(e) {
    e.preventDefault();
    let page = this.props.currentPage - 1;
    if (page > 0)
      this.props.fetchNextPage(page);
  },

  handleNextClick: function(e) {
    e.preventDefault();
    if (this.props.nextPage)
      this.props.fetchNextPage(this.props.nextPage);
  },

  render: function() {
    let parts = _.map(this.props.parts, function(part, index) {
      return (
        <PartItem key={index} {...part} handleItemClick={this.handleItemClick} />
      );
    }.bind(this));

    let loading;
    if (this.props.isFetching) {
      loading = (<div className="col-xs-12 text-center"><i className="fa fa-spin fa-spinner fa-3x"></i></div>);
    } else if (parts.length == 0) {
      parts = (<div className="col-xs-12">No results for <em>{this.props.query}</em>.</div>);
    }

    let prevClass = (this.props.currentPage == 1 ? 'disabled' : ''),
        nextClass = (this.props.nextPage ? '' : 'disabled');

    let pagination;
    if (this.props.currentPage > 1 || this.props.nextPage) {
      pagination = (
        <div className="col-xs-12 text-center">
          <div className="pagination">
            <ul className="pagination">
              <li className={prevClass}>
                <a href="javascript:void(0)" onClick={this.handlePrevClick}>&larr; Previous</a>
              </li>
              <li className={nextClass}>
                <a href="javascript:void(0)" onClick={this.handleNextClick}>Next &rarr;</a>
              </li>
            </ul>
          </div>
        </div>
      );
    }

    return (
      <div className="parts-container row">
        {loading}
        {parts}
        {pagination}
      </div>
    );
  },
});

export default PartsContainer;