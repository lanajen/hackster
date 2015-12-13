import React from 'react';

var File = React.createClass({

  render: function() {
    return (
      <div className="react-editor-file" data-hash={this.props.hash}>
        <i className="fa fa-file-o fa-2x"></i>
        <a href={this.props.fileData.url}>{this.props.fileData.content}</a>
      </div>
    );
  }

});

export default File;