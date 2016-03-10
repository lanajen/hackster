import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { selectParts, selectedQueryKey, fetchPartsIfNeeded, followOrUnfollowPart, initialFetchFollowing, SortFilters } from '../actions';
import PartsContainer from '../components/PartsContainer';
import SearchContainer from '../components/SearchContainer';

const App = React.createClass({

  componentDidMount() {
    const { dispatch, selectedQueryKey } = this.props;
    dispatch(initialFetchFollowing());
    dispatch(fetchPartsIfNeeded(selectedQueryKey));
  },

  componentWillReceiveProps(nextProps) {
    if (nextProps.selectedQueryKey !== this.props.selectedQueryKey) {
      const { dispatch, selectedQueryKey } = nextProps;
      dispatch(fetchPartsIfNeeded(selectedQueryKey));
    }
  },

  dispatchSelectParts: function(options) {
    const { dispatch, request } = this.props;
    let newReq = Object.assign({}, request, options);
    dispatch(selectParts(newReq));

    let currentY = window.scrollY;
    if (currentY > 0) {
      let y = currentY;
      let interval = currentY / (200 / 10);  // we want it finish after 200ms and each iteration is 10ms
      function up() {
        y -= interval;
        y = Math.max(0, y);
        window.scrollTo(0, y);
        if (y == 0)
          clearInterval(id)
      }
      let id = setInterval(up, 10)  // draw every 10ms
    }
  },

  handleFetchNextPage: function(page){
    this.dispatchSelectParts({ page });
  },

  handlePartClick: function(id) {
    const { dispatch } = this.props;
    dispatch(followOrUnfollowPart(id));
  },

  handleOnFilterChange: function(filter) {
    this.dispatchSelectParts({ filter, page: 1 });
  },

  handleOnSearch: function(q) {
    this.dispatchSelectParts({ query: q, page: 1 });
  },

  render: function() {
    const { selectedQueryKey, parts, isFetching, nextPage, currentPage, request } = this.props;
    return (
      <div className='toolbox-selector'>
        <h1>Fill up your toolbox by selecting components, apps and tools you own or are using</h1>
        <div className="row">
          <div className="col-md-6">
            <SearchContainer filter={request.filter} onFilterChange={this.handleOnFilterChange} onSearch={this.handleOnSearch} />
          </div>
          <div className="col-md-6">
            <a href={this.props.doneLink} className="btn btn-primary">{"Done!"}</a>
            <a href={this.props.nextLink} className="btn btn-link btn-sm">{"I'll do this later"}</a>
          </div>
        </div>
        <PartsContainer isFetching={isFetching} parts={parts} nextPage={nextPage} currentPage={currentPage} fetchNextPage={this.handleFetchNextPage} handlePartClick={this.handlePartClick} query={request.query} />
      </div>
    );
  }

});

function mapStateToProps(state) {
  const { selectedQueryKey, partsByQueryKey, partsById, followedPartIds } = state;
  const {
    isFetching,
    items: partIds,
    nextPage,
    currentPage,
    request
  } = partsByQueryKey[selectedQueryKey] || {
    isFetching: true,
    items: [],
    request: { filter: SortFilters.MOST_FOLLOWED }
  };
  let parts = getPartsFromIds(partsById, partIds, followedPartIds);

  return {
    selectedQueryKey,
    parts,
    isFetching,
    nextPage,
    currentPage,
    request
  };
}

function getPartsFromIds(partsById = {}, partIds = [], followedPartIds = []) {
  return partIds.map(function(id, i) {
    let part = partsById[id];
    part.isFollowing = followedPartIds.indexOf(id) > -1 ? true : false;
    return part;
  });
}

App.PropTypes = {
  doneLink: PropTypes.string.isRequired,
  nextLink: PropTypes.string.isRequired
};

export default connect(mapStateToProps)(App);