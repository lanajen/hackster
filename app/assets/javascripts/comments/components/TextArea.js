import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';

export default class TextArea extends Component {
  constructor(props) {
    super(props);
    this.handleOnChange = this.handleOnChange.bind(this);
    this.handleKeyDown = this.handleKeyDown.bind(this);

    this.state = { rows: 3 };
  }

  componentDidMount() {
    let textarea = React.findDOMNode(this.refs.textarea);

    if(textarea.scrollHeight > textarea.clientHeight) {
      let rows = Math.floor( parseInt(textarea.scrollHeight, 10) / parseInt(20, 10) );
      this.setState({ rows: rows });
    }
  }

  autoFocus() {
    ReactDOM.findDOMNode(this).focus();
  }

  clearTextArea() {
    ReactDOM.findDOMNode(this).value = '';
  }

  resetForm() {
    this.setState({ rows: 3 });
  }

  handleOnChange(e) {
    let textarea = React.findDOMNode(this.refs.textarea);

    if(textarea.scrollHeight > textarea.clientHeight) {
      this.setState({ rows: this.state.rows+1 });
    }
  }

  handleKeyDown(e) {
    let textarea = React.findDOMNode(this.refs.textarea);

    if(e.keyCode === 8 && this.state.rows > 3) {
      let lines = textarea.value.split('\n');

      if(!lines[lines.length-1].length) {
        this.setState({ rows: this.state.rows-1 });
      }
    }
  }

  render() {
    let placeholder = this.props.placeholder || 'Write a comment';

    let view = this.props.viewState === 'write'
             ? (<textarea ref="textarea"
                          className="comments-textarea"
                          placeholder={placeholder}
                          rows={this.state.rows}
                          defaultValue={this.props.value}
                          onChange={this.handleOnChange}
                          onKeyDown={this.handleKeyDown}>
                </textarea>)
             : (<div className="comments-preview" dangerouslySetInnerHTML={{ __html: this.props.value }}></div>);

    return (view);
  }
}

TextArea.PropTypes = {
  placeholder: PropTypes.string,
  viewState: PropTypes.string.isRequired,
  value: PropTypes.string.isRequired
};