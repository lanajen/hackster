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
    const { dispatch, currentThread, csrfToken } = this.props;
    dispatch(doSubmitComment(body, currentThread.id, csrfToken));
  },

  handleDecisionFormSubmit: function(data) {
    const { dispatch, projectId, csrfToken } = this.props;
    dispatch(doSubmitDecision(data, projectId, csrfToken));
  },

  render: function() {
    return (
      <div className='review-tool'>
        {this.renderItemsContainer()}
      </div>
    );
  },

  renderItemsContainer: function() {
    const { currentThread, formStates, canAdmin, isEditable, showDecisionForm } = this.props;

    if (this.props.currentThread.isLoaded) {
      let permissions = {
        canAdmin: canAdmin,
        canComment: isEditable,
        canCreateDecision: showDecisionForm && canAdmin,
        canUpdateDecision: isEditable && currentThread.hasDecisions && canAdmin
      };

      return (<ItemsContainer items={currentThread.items} hasDecisions={currentThread.hasDecisions} formStates={formStates} onCommentFormSubmit={this.handleCommentFormSubmit} onDecisionFormSubmit={this.handleDecisionFormSubmit} permissions={permissions} showDecisionForm={showDecisionForm} threadStatus={currentThread.status} />);
    } else {
      return (<div className="text-center"><i className="fa fa-spin fa-spinner" /></div>);
    }
  }
});

function mapStateToProps(state) {
  const { currentThread, formStates } = state;
  let isEditable = !_.some(_.map(['new', 'closed'], function(v) { if (v == currentThread.status) return true; })) && !currentThread.locked;
  let showDecisionForm = isEditable && !currentThread.hasDecisions;

  return {
    currentThread,
    formStates,
    isEditable,
    showDecisionForm
  };
}

export default connect(mapStateToProps)(App);