import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';
import TextArea from './TextArea';
import smoothScroll from '../utils/SmoothScroll';

export default class CommentForm extends Component {
  constructor(props) {
    super(props);
    this.handlePostClick = this.handlePostClick.bind(this);
  }

  componentDidMount() {
    if(this.props.parentId && window) {
      smoothScroll((ReactDOM.findDOMNode(this).getBoundingClientRect().top + window.pageYOffset) - (window.innerHeight / 2));
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

    let form = {
      comment: {
        'raw_body': ReactDOM.findDOMNode(this.refs.textarea).value,
        'parent_id': this.props.parentId
      },
      commentable: this.props.commentable
    };
    this.props.onPost(form);
  }

  render() {
    let buttonLabel = this.props.formData.isLoading
                    ? (<i className="fa fa-spinner fa-spin"></i>)
                    : ('Post');
    let rootClass = this.props.isReply ? 'comments-form reply' : 'comments-form';

    return (
      <div className={rootClass}>
        <TextArea ref="textarea" placeholder={this.props.placeholder} />
        <div className="comments-form-button-container">
          <button className="btn btn-primary" onClick={this.handlePostClick}>{buttonLabel}</button>
        </div>
      </div>
    );
  }
}

CommentForm.PropTypes = {
  parentId: PropTypes.number.isRequired,
  commentable: PropTypes.object.isRequired,
  formData: PropTypes.object.isRequired,
  isReply: PropTypes.bool,
  onPost: PropTypes.func.isRequired,
  placeholder: PropTypes.string
};