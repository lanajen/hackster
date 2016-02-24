import React from 'react';
import ReactDOM from 'react-dom';

const CommentForm = React.createClass({
  getInitialState: function() {
    return {
      value: ''
    }
  },

  componentWillReceiveProps: function(nextProps) {
    if (typeof(nextProps.formState.textAreaValue) != 'undefined') {
      this.setState({
        value: nextProps.formState.textAreaValue
      });
    }
  },

  handleSubmit: function(e) {
    e.preventDefault();
    this.submitComment();
  },

  handleDecisionClick: function(e) {
    e.preventDefault();

    this.submitComment();
    let data = {
      'decision': e.target.dataset.decision
    }
    this.props.onDecisionSubmit(data);
  },

  handleTextAreaChange: function(e) {
    this.setState({
      value: e.target.value
    });
  },

  submitComment: function() {
    if (this.state.value != '') {
      this.props.onCommentSubmit(this.state.value);
    }
  },

  render: function() {
    const { formState } = this.props;

    return (
      <div className='r-comments review-item'>
        <div className='comments-form'>
          <textarea ref="textarea" className='comments-textarea' placeholder='Write a comment' value={this.state.value} onChange={this.handleTextAreaChange} />
          <div className='comments-form-button-container'>
            <button type="submit" className='btn btn-primary btn-sm' disabled={formState.isDisabled} onClick={this.handleSubmit}>Comment</button>
            {this.renderSecondaryBtn()}
          </div>
        </div>
      </div>
    );
  },

  renderSecondaryBtnLabel: function() {
    if (this.state.value == '') {
      return 'Update decision';
    } else {
      return 'Comment and update decision';
    }
  },

  renderSecondaryBtn: function() {
    if (!this.props.canUpdateDecision) return;

    return (
      <div className="btn-group">
        <button type="button" className="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
          {this.renderSecondaryBtnLabel()} <span className="caret"></span>
        </button>
        <ul className="dropdown-menu">
          <li><a href="javascript:void(0)" onClick={this.handleDecisionClick} data-decision="needs_work">Mark as needs work</a></li>
          <li><a href="javascript:void(0)" onClick={this.handleDecisionClick} data-decision="approve">Approve</a></li>
          <li><a href="javascript:void(0)" onClick={this.handleDecisionClick} data-decision="reject">Reject</a></li>
        </ul>
      </div>
    );
  }
});

export default CommentForm;