import React from 'react';
import PartItem from './PartItem';

const PartsContainer = React.createClass({
  handleMoreClick: function(e) {
    e.preventDefault();
    this.props.fetchNextPage(this.props.nextPage);
  },

  render: function() {
    let parts = _.map(this.props.parts, function(part, index) {
      return (
        <PartItem key={index} {...part} />
      );
    });
    let loading;
    if (this.props.isFetching) {
      loading = (<i className="fa fa-spin fa-spinner"></i>);
    }
    let more;
    if (this.props.nextPage) {
      more = (<div className="col-xs-12"><a href="javascript:void(0)" onClick={this.handleMoreClick}>Load more</a></div>);
    }

    return (
      <div className="parts-container row">
        {loading}
        {parts}
        {more}
      </div>
    );
  },
});

export default PartsContainer;