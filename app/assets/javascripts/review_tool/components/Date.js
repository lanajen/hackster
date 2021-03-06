import React from 'react';

const DateComponent = React.createClass({
  render: function() {
    const { createdAt } = this.props;

    if (!createdAt) return (<span />);

    let date= (window ? window.moment(createdAt).fromNow() : createdAt);

    return (
      <span className="review-item-date">
        <span> </span>
        {date}
      </span>
    );
  }
});

export default DateComponent;