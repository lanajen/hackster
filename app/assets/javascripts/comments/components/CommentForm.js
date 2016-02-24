import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';
import TextArea from './TextArea';
import smoothScroll from '../utils/SmoothScroll';
import markdown from '../utils/Markdown'

export default class CommentForm extends Component {
  constructor(props) {
    super(props);
    this.handlePostClick = this.handlePostClick.bind(this);
    this.handleCancelClick = this.handleCancelClick.bind(this);
    this.setActiveTab = this.setActiveTab.bind(this);
    this._checkActiveButton = this._checkActiveButton.bind(this);

    this.state = { activeTab: 'write', isLoading: false, textValue: null, markdown: null };
  }

  componentWillMount() {
    this.setState({ textValue: this.props.isEditing ? this.props.rawBody : '' });
  }

  componentDidMount() {
    if(this.props.parentId && window && !this.props.isEditing) {
      smoothScroll((ReactDOM.findDOMNode(this).getBoundingClientRect().top + window.pageYOffset) - (window.innerHeight / 2));
      this.refs.textarea.autoFocus();
    }
  }

  componentWillReceiveProps(nextProps) {
    if(!nextProps.formData.isLoading && this.state.isLoading) {
      this.setState({ isLoading: false });
    }
  }

  componentDidUpdate(nextProps) {
    if(!nextProps.formData.isLoading && this.props.formData.isLoading) {
      this.refs.textarea.clearTextArea();
    }
  }

  handlePostClick(e) {
    e.preventDefault();

    let body = this.state.activeTab === 'preview'
                ? this.state.textValue
                : ReactDOM.findDOMNode(this.refs.textarea).value;

    this.setActiveTab('write');

    if (body !== this.props.rawBody && body.length > 0) {
      let form = {
        comment: {
          'raw_body': body,
          'parent_id': this.props.parentId
        },
        commentable: this.props.commentable
      };
      this.props.onPost(form);
      this.setState({ isLoading: true });
      this.refs.textarea.resetForm();
    } else if (body === this.props.rawBody) {
      this.props.dismiss();
    }
  }

  handleCancelClick(e) {
    e.preventDefault();
    this.props.dismiss();
  }

  setActiveTab(name) {
    let body = ReactDOM.findDOMNode(this.refs.textarea).value;
    if(name === this.state.activeTab) { return; }

    this.setState({
      activeTab: name,
      textValue: name === 'preview' ? body : this.state.textValue,
      markdown: name === 'preview' ? markdown.render(body) : this.state.markdown
     });
  }

  _checkActiveButton(name) {
    return (name === this.state.activeTab) ? 'comments-form-tab active' : 'comments-form-tab';
  }

  render() {
    let rootClass = this.props.isReply ? 'comments-form reply' : 'comments-form';
    let buttonLabel = this.props.isEditing ? 'Update Comment' : 'Post';
    let buttonBody = this.state.isLoading
                    ? (<i className="fa fa-spinner fa-spin"></i>)
                    : (buttonLabel);

    let actions = this.props.dismissable
                ? (<div>
                     <button className="btn btn-primary" onClick={this.handlePostClick}>{buttonBody}</button>
                     <a href="javascript:void(0);" className="btn-link btn" onClick={this.handleCancelClick}>Cancel</a>
                   </div>)
                : (<button className="btn btn-primary" onClick={this.handlePostClick}>{buttonBody}</button>);

    let textValue = this.state.activeTab === 'write' ? this.state.textValue : this.state.markdown;

    let body = (
      <div className={rootClass}>
        <nav className="comments-form-nav">
          <a href="javascript:void(0);" className={this._checkActiveButton('write')} onClick={this.setActiveTab.bind(this, 'write')}>Write</a>
          <a href="javascript:void(0);" className={this._checkActiveButton('preview')} onClick={this.setActiveTab.bind(this, 'preview')}>
            <img src='/assets/markdown-mark.png' className="markdown-supported" />
            Preview
          </a>
        </nav>
        <TextArea ref="textarea" placeholder={this.props.placeholder} value={textValue} viewState={this.state.activeTab} />
        <div className="comments-form-button-container">
          {actions}
        </div>
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
  commentId: PropTypes.number,
  dismiss: PropTypes.func,
  dismissable: PropTypes.bool,
  formData: PropTypes.object.isRequired,
  isEditing: PropTypes.bool,
  isReply: PropTypes.bool,
  onPost: PropTypes.func.isRequired,
  placeholder: PropTypes.string,
  rawBody: PropTypes.string
};