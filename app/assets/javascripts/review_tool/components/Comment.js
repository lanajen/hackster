import React from 'react';
import ItemHeader from './ItemHeader';

const Comment = React.createClass({
  render: function() {
    const { body } = this.props;

    return (
      <div className=''>
        <ItemHeader action='commented' {...this.props} />
        <div className='review-item-body' dangerouslySetInnerHTML={{ __html: body }} />
      </div>
    );
  }
});

export default Comment;