import React from 'react';
import DecisionForm from './DecisionForm';
import Decision from './Decision';
import Event from './Event';
import Comment from './Comment';
import CommentForm from './CommentForm';

const ItemsContainer = React.createClass({
  handleCommentFormSubmit: function(data) {
    this.props.onCommentFormSubmit(data);
  },

  handleDecisionFormSubmit: function(data) {
    this.props.onDecisionFormSubmit(data);
  },

  render: function() {
    return (
      <div className='review-items-container'>
        {this.renderItems()}
        {this.renderDecisionForm()}
        {this.renderCommentForm()}
      </div>
    );
  },

  renderItems: function() {
    let items = this.props.items.map((item, index) => {
      return (
        <div key={index} className={`review-item review-item-${item.type}`}>
          {this.renderItem(item)}
        </div>
      );
    });

    if (!this.props.hasDecisions && !this.props.threadStatus == 'closed') {
      items.push((
        <div key='somerandomkey' className='review-item review-item-event'>
          <div className='review-item-header'>
            <i className="fa fa-clock-o" />
            <span>No feedback has been left yet</span>
          </div>
        </div>
      ));
    }

    if (items.length) {
      return items;
    } else {
      return (
        <div className='review-item review-item-event'>
          <div className='review-item-header'>
            <i className="fa fa-clock-o" />
            <span>Nothing to see yet</span>
          </div>
        </div>
      );
    }
  },

  renderItem: function(item) {
    switch (item.type) {
      case 'decision':
        return (<Decision canModerate={this.props.permissions.canModerate} {...item} />);
      case 'comment':
        return (<Comment {...item} />);
      case 'event':
        return (<Event {...item} />);
    }
  },

  renderDecisionForm: function() {
    const { permissions, showDecisionForm } = this.props;

    if (!showDecisionForm) return;

    if (permissions.canCreateDecision) {
      return (<DecisionForm onSubmit={this.handleDecisionFormSubmit} formState={this.props.formStates.decision} />);
    } else {
      return (
        <div className='review-item review-item-event'>
          <div className='review-item-header'>
            <i className="fa fa-clock-o" />
            <span>Awaiting moderator review</span>
          </div>
        </div>
      );
    }
  },

  renderCommentForm: function() {
    const { permissions } = this.props;

    if (!permissions.canComment) return;

    return (
      <CommentForm onCommentSubmit={this.handleCommentFormSubmit} onDecisionSubmit={this.handleDecisionFormSubmit} formState={this.props.formStates.comment} canUpdateDecision={permissions.canUpdateDecision} />
    );
  }
});

export default ItemsContainer;
