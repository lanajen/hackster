import React from 'react';

const Date = React.createClass({
  render: function() {
    const { createdAt } = this.props;

    if (!createdAt) return (<span />);

    let date= (window ? window.moment(createdAt).fromNow() : createdAt);

    return (
      <span className="review-item-date">{date}</span>
    );
  }
});

export default Date;