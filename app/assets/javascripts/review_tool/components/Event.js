import React from 'react';
import User from './User';
import DateComponent from './Date';

const Event = React.createClass({
  render: function() {
    const { message, createdAt } = this.props;

    return (
      <div className='review-item-header'>
        <User {...this.props} />
        <span className="review-item-action">{message}</span>
        <DateComponent createdAt={createdAt} />
      </div>
    );
  }
});

export default Event;