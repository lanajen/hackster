import React, { Component, PropTypes } from 'react';
import TextArea from './TextArea';
import smoothScroll from '../utils/SmoothScroll';

export default class CommentForm extends Component {
  constructor(props) {
    super(props);
    this.handlePostClick = this.handlePostClick.bind(this);
  }

  componentDidMount() {
    if(this.props.parentId && window) {
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

  render() {
    let buttonLabel = this.props.formData.isLoading
                    ? (<i className="fa fa-spinner fa-spin"></i>)
                    : ('Post')
    return (
      <div className="comments-form">
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
  onPost: PropTypes.func.isRequired,
  placeholder: PropTypes.string
};