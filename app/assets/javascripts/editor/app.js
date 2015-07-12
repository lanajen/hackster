import React from 'react';
import Editor from './components/Editor';

var App = React.createClass({

  render: function() {
    return (
      <Editor {...this.props} />
    );
  }

});

module.exports = App;