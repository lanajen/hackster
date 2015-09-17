import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { selectParts, selectedQueryKey, fetchPartsIfNeeded, followPart, unfollowPart } from '../actions';
import PartsContainer from '../components/PartsContainer';
import SearchContainer from '../components/SearchContainer';

const App = React.createClass({

  // getInitialState() {
  //   return {
  //     parts: store.getState().parts
  //   };
  // },

  componentDidMount() {
    const { dispatch, selectedQueryKey } = this.props;
    dispatch(fetchPartsIfNeeded(selectedQueryKey));
  },

  componentWillReceiveProps(nextProps) {
    console.log('new props!', nextProps);
    if (nextProps.selectedQueryKey !== this.props.selectedQueryKey) {
      const { dispatch, selectedQueryKey } = nextProps;
      dispatch(fetchPartsIfNeeded(selectedQueryKey));
    }
  },

  handleFetchNextPage: function(page){
    const { dispatch, request } = this.props;
    request.page = page;
    dispatch(selectParts(request));
  },

  render: function() {
    const { selectedQueryKey, parts, isFetching, nextPage, request } = this.props;

    return (
      <div className='toolbox-selector'>
        <SearchContainer filter={request.filter} />
        <PartsContainer isFetching={isFetching} parts={parts} nextPage={nextPage} fetchNextPage={this.handleFetchNextPage} />
      </div>
    );
  }

});

function mapStateToProps(state) {
  console.log('STATE', state);
  const { selectedQueryKey, partsByQueryKey, partsById } = state;
  const {
    isFetching,
    items: partIds,
    nextPage,
    request
  } = partsByQueryKey[selectedQueryKey] || {
    isFetching: true,
    items: [],
    request: {}
  };
  let parts = getPartsFromIds(partsById, partIds);

  return {
    selectedQueryKey,
    parts,
    isFetching,
    nextPage,
    request
  };
}

function getPartsFromIds(partsById = {}, partIds = []) {
  return partIds.map((id, i) => partsById[id]);
}

export default connect(mapStateToProps)(App);