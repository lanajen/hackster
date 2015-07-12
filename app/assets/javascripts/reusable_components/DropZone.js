import React from 'react';

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

    this.setState({
      isDragActive: false
    });

    var files;
    if (e.dataTransfer) {
      files = e.dataTransfer.files;
    } else if (e.target) {
      files = e.target.files;
    }

    for (var i = 0; i < files.length; i++) {
      files[i].preview = URL.createObjectURL(files[i]);
    }

    if (this.props.onDrop) {
      files = Array.prototype.slice.call(files);
      this.props.onDrop(files);
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