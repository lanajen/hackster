import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';

export default class TextArea extends Component {
  constructor(props) {
    super(props);
  }

  autoFocus() {
    ReactDOM.findDOMNode(this).focus();
  }

  clearTextArea() {
    ReactDOM.findDOMNode(this).value = '';
  }

  render() {
    let placeholder = this.props.placeholder || 'Write a comment';

    return (
      <textarea className="comments-textarea" placeholder={placeholder} rows={3}></textarea>
    );
  }
}

TextArea.PropTypes = {
  placeholder: PropTypes.string
};