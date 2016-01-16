import React, {Component, PropTypes} from 'react';
import ReactDOM from 'react-dom';
import Helpers from '../utils/Helpers';

export default class DropZone extends Component {
  constructor(props) {
    super(props);
    this.onDragLeave = this.onDragLeave.bind(this);
    this.onDragOver = this.onDragOver.bind(this);
    this.onDrop = this.onDrop.bind(this);

    this.state = { isDragActive: false };
  }

  onDragLeave(e) {
    this.setState({ isDragActive: false });
  }

  onDragOver(e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = "copy";
    this.setState({ isDragActive: true });
  }

  onDrop(e) {
    e.preventDefault();
    let files, filteredFiles;

    this.setState({ isDragActive: false });

    if(e.dataTransfer) {
      files = e.dataTransfer.files;
    } else if (e.target) {
      files = e.target.files;
    }

    if(this.props.onDrop) {
      files = [].slice.call(files);
      files = files.filter(file => Helpers.isImageValid(file.type));
      this.props.onDrop(files);
    }
  }

  render() {
    let className = this.props.className || 'dropzone';
    if(this.state.isDragActive) { className += ' active'; }

    let style = this.props.style || {};

    return (
      <div className={className} style={style} onDragLeave={this.onDragLeave} onDragOver={this.onDragOver} onDrop={this.onDrop}>
        <input style={{ display: 'none' }} type="file" multiple={this.props.multiple || true} onChange={this.onDrop} />
        {this.props.children}
      </div>
    );
  }
}

DropZone.PropTypes = {
  className: PropTypes.string,
  onDrop: PropTypes.func.isRequired,
  size: PropTypes.number,
  style: PropTypes.object,
  multiple: PropTypes.string
};