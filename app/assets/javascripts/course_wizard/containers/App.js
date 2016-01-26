import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import {  } from '../actions';
import UniversityComponent from '../components/UniversityComponent';

const App = React.createClass({

  handleCommentFormSubmit: function(body) {
    const { dispatch, currentThread, csrfToken } = this.props;
    dispatch(doSubmitComment(body, currentThread.id, csrfToken));
  },

  render: function() {
    const { } = this.props;

    return (
      <div className='course-wizard'>
        <UniversityComponent />
      </div>
    );
  }
});

function mapStateToProps(state) {
  const { store } = state;

  return {
    store
  };
}

export default connect(mapStateToProps)(App);