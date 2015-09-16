import React from 'react';
import Helpers from '../utils/Helpers'; 

const Dropzone = React.createClass({
  getInitialState: function() {
    return {
      isDragActive: false
    }
  },

  propTypes: {
    onDrop: React.PropTypes.func.isRequired,
    size: React.PropTypes.number,
    style: React.PropTypes.object
  },

  onDragLeave: function(e) {
    this.setState({
      isDragActive: false
    });
  },

  onDragOver: function(e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = "copy";

    this.setState({
      isDragActive: true
    });
  },

  onDrop: function(e) {
    e.preventDefault();
    let files, filteredFiles;

    this.setState({
      isDragActive: false
    });

    if(e.dataTransfer) {
      files = e.dataTransfer.files;
    } else if (e.target) {
      files = e.target.files;
    }

    if(this.props.onDrop) {
      files = Array.prototype.slice.call(files);
      // Filter files and remove unaccepted extensions.
      filteredFiles = files.filter(function(file) {
        if(Helpers.isImageValid(file.type)) {
          return file;
        } else {
          return false;
        }
      });
      this.props.onDrop(filteredFiles);
    }
  },

  onClick: function () {
    this.refs.fileInput.getDOMNode().click();
  },

  render: function() {

    var className = this.props.className || 'dropzone';
    if (this.state.isDragActive) {
      className += ' active';
    };

    var style = this.props.style || {
      width: this.props.size || 100,
      height: this.props.size || 100,
      borderStyle: this.state.isDragActive ? "solid" : "dashed"
    };

    if (this.props.className) {
      style = this.props.style;
    }

    return (
        React.createElement("div", {className: className, style: style, onDragLeave: this.onDragLeave, onDragOver: this.onDragOver, onDrop: this.onDrop},
            React.createElement("input", {style: {display: 'none'}, type: "file", multiple: true, ref: "fileInput", onChange: this.onDrop}),
            this.props.children
        )
    );
  }

});

export default Dropzone;