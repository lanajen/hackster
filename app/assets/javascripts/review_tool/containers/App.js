import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { initialFetch, doSubmitDecision } from '../actions';
import Form from '../components/Form';

const App = React.createClass({

  componentDidMount() {
    const { dispatch, projectId } = this.props;
    dispatch(initialFetch(projectId));
  },

  // componentWillReceiveProps(nextProps) {
  //   if (nextProps.selectedQueryKey !== this.props.selectedQueryKey) {
  //     const { dispatch, selectedQueryKey } = nextProps;
  //     dispatch(fetchPartsIfNeeded(selectedQueryKey));
  //   }
  // },

  handleFormSubmit: function(data) {
    const { dispatch, projectId } = this.props;
    dispatch(doSubmitDecision(data, projectId));
  },

  render: function() {
    // const { selectedQueryKey, parts, isFetching, nextPage, currentPage, request } = this.props;
    const { currentThread, decisions, request } = this.props;
    return (
      <div className='review-tool'>
        <Form onSubmit={this.handleFormSubmit} />
      </div>
    );
  }

});

function mapStateToProps(state) {
  const { currentThread, decisions } = state;
  // const { selectedQueryKey, partsByQueryKey, partsById, followedPartIds } = state;
  // const {
  //   isFetching,
  //   items: partIds,
  //   nextPage,
  //   currentPage,
  //   request
  // } = partsByQueryKey[selectedQueryKey] || {
  //   isFetching: true,
  //   items: [],
  //   request: { filter: SortFilters.MOST_FOLLOWED }
  // };
  // let parts = getPartsFromIds(partsById, partIds, followedPartIds);

  return {
    currentThread,
    decisions
    // selectedQueryKey,
    // parts,
    // isFetching,
    // nextPage,
    // currentPage,
    // request
  };
}

export default connect(mapStateToProps)(App);