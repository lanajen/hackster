import React from 'react';

const App = React.createClass({

  render: function() {
    return (
      <span>
        {this.timeToNow(this.props.timestamp)}
      </span>
    );
  },

  timeToNow: function(timestamp) {
    if (!timestamp) return;

    let amount, unit;
    let now = Date.now() / 1000;
    let seconds = Math.round(timestamp - now);

    if (seconds > 60 * 60 * 100) {  // 100 hours
      amount = Math.round(seconds / 60 / 60 / 24);
      unit = 'day';
    } else if (seconds > 60 * 100) {  // 100 minutes
      amount = Math.round(seconds / 60 / 60);
      unit = 'hour';
    } else if (seconds > 100) {  // 100 seconds
      amount = Math.round(seconds / 60);
      unit = 'minute';
    } else if (seconds > 0) {
      amount = seconds;
      unit = 'second';
    } else {
      amount = 0;
      unit = 'second';
    }

    let time = amount + ' ' + unit;
    if (amount != 1) time += 's';

    return time;
  }

});

export default App;