import React from 'react';
import DateComponent from './Date';
import User from './User';

const ItemHeader = React.createClass({
  render: function() {
    const { createdAt } = this.props;

    return (
      <div className='review-item-header'>
        <User {...this.props} />
        <span className='review-item-action'>{this.props.action}</span>
        <DateComponent createdAt={createdAt} />
      </div>
    );
  }
});

export default ItemHeader;