import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { initialFetch, doSubmitDecision, doSubmitComment } from '../actions';
import ItemsContainer from '../components/ItemsContainer';

const App = React.createClass({

  componentDidMount() {
    const { dispatch, projectId } = this.props;
    dispatch(initialFetch(projectId));
  },

  handleCommentFormSubmit: function(body) {
    const { dispatch, currentThread } = this.props;
    dispatch(doSubmitComment(body, currentThread.id));
  },

  handleDecisionFormSubmit: function(data) {
    const { dispatch, projectId } = this.props;
    dispatch(doSubmitDecision(data, projectId));
  },

  render: function() {
    return (
      <div className='review-tool'>
        {this.renderItemsContainer()}
      </div>
    );
  },

  renderItemsContainer: function() {
    const { currentThread, formStates, userRole, isAuthor, isEditable, showDecisionForm } = this.props;

    let canAdmin = !isAuthor && ['admin', 'hackster_moderator', 'super_moderator'].indexOf(userRole) > -1;
    let canModerate = !isAuthor && (canAdmin || ['moderator'].indexOf(userRole) > -1);

    if (this.props.currentThread.isLoaded) {
      let permissions = {
        canAdmin: canAdmin,
        canModerate: canModerate,
        canComment: isEditable,
        canCreateDecision: showDecisionForm && canModerate,
        canUpdateDecision: isEditable && currentThread.hasDecisions && canModerate
      };

      return (<ItemsContainer items={currentThread.items} hasDecisions={currentThread.hasDecisions} formStates={formStates} onCommentFormSubmit={this.handleCommentFormSubmit} onDecisionFormSubmit={this.handleDecisionFormSubmit} permissions={permissions} showDecisionForm={showDecisionForm} threadStatus={currentThread.status} />);
    } else {
      return (<div className="text-center"><i className="fa fa-spin fa-spinner" /></div>);
    }
  }
});

function mapStateToProps(state) {
  const { currentThread, formStates } = state;
  let isEditable = !_.some(_.map(['closed'], function(v) { if (v == currentThread.status) return true; })) && !currentThread.locked;
  let showDecisionForm = isEditable && !currentThread.hasDecisions;

  return {
    currentThread,
    formStates,
    isEditable,
    showDecisionForm
  };
}

export default connect(mapStateToProps)(App);