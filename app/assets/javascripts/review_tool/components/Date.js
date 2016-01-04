import React from 'react';

const Date = React.createClass({
  render: function() {

    return (
      <span className="review-item-date">{this.renderDate()}</span>
    );
  },

  renderDate: function() {
    const { createdAt } = this.props;

    if (!createdAt) return;

    return (window ? window.moment(createdAt).fromNow() : createdAt);
  }
});

export default Date;