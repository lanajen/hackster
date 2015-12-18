import React, { Component, PropTypes } from 'react';
import TextArea from './TextArea';
import smoothScroll from '../utils/SmoothScroll';

export default class CommentForm extends Component {
  constructor(props) {
    super(props);
    this.handlePostClick = this.handlePostClick.bind(this);
    this.handleCancelClick = this.handleCancelClick.bind(this);
    this.setActiveTab = this.setActiveTab.bind(this);
    this._checkActiveButton = this._checkActiveButton.bind(this);

    this.state = { activeTab: 'write' };
  }

  componentDidMount() {
    if(this.props.parentId && window && !this.props.isEditing) {
      smoothScroll((React.findDOMNode(this).getBoundingClientRect().top + window.pageYOffset) - (window.innerHeight / 2));
      this.refs.textarea.autoFocus();
    }
  }

  componentDidUpdate(nextProps) {
    if(!nextProps.formData.isLoading && this.props.formData.isLoading) {
      this.refs.textarea.clearTextArea();
    }
  }

  handlePostClick(e) {
    e.preventDefault();
    let body = React.findDOMNode(this.refs.textarea).value;

    if(body.length > 0) {
      let form = {
        comment: {
          'raw_body': body,
          'parent_id': this.props.parentId
        },
        commentable: this.props.commentable
      };
      this.props.onPost(form);
    }
  }

  handleCancelClick(e) {
    e.preventDefault();
    this.props.cancelEditing();
  }

  setActiveTab(name) {
    this.setState({ activeTab: name });
  }

  _checkActiveButton(name) {
    return (name === this.state.activeTab) ? 'comments-form-tab active' : 'comments-form-tab';
  }

  render() {
    let rootClass = this.props.isReply ? 'comments-form reply' : 'comments-form';
    let buttonLabel = this.props.isEditing ? 'Update Comment' : 'Post';
    let buttonBody = this.props.formData.isLoading
                    ? (<i className="fa fa-spinner fa-spin"></i>)
                    : (buttonLabel);

    let actions = this.props.isEditing
                ? (<div className="comments-form-button-container">
                     <a href="javascript:void(0);" className="comments-form-cancel-button" onClick={this.handleCancelClick}>Cancel</a>
                     <button className="btn btn-primary" onClick={this.handlePostClick}>{buttonBody}</button>
                   </div>)
                : (<div className="comments-form-button-container">
                     <button className="btn btn-primary" onClick={this.handlePostClick}>{buttonBody}</button>
                   </div>);

    let value = this.props.isEditing ? this.props.rawBody : '';

    let body = (
      <div className={rootClass}>
        <nav className="comments-form-nav">
          <a href="javascript:void(0);" className={this._checkActiveButton('write')} onClick={this.setActiveTab.bind(this, 'write')}>Write</a>
          <a href="javascript:void(0);" className={this._checkActiveButton('preview')} onClick={this.setActiveTab.bind(this, 'preview')}>Preview</a>
        </nav>
        <TextArea ref="textarea" placeholder={this.props.placeholder} value={value} />
        {actions}
      </div>
    );

    return (
      body
    );
  }
}

CommentForm.PropTypes = {
  parentId: PropTypes.number.isRequired,
  commentable: PropTypes.object.isRequired,
  formData: PropTypes.object.isRequired,
  isEditing: PropTypes.bool,
  isReply: PropTypes.bool,
  onPost: PropTypes.func.isRequired,
  placeholder: PropTypes.string,
  rawBody: PropTypes.string
};