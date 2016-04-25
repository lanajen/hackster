import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as AdminActions from '../actions/admin';
import * as ContestActions from '../actions/contest';

import SubmissionsTable from '../components/SubmissionsTable';
import TableFilter from '../components/TableFilter';

class Admin extends Component {
  constructor(props) {
    super(props);

    this.handleFilterUpdate = this.handleFilterUpdate.bind(this);
    this.handleActivePhasePromotion = this.handleActivePhasePromotion.bind(this);
    this.handleSubmissionAction = this.handleSubmissionAction.bind(this);
    this.handlePaginationClick = this.handlePaginationClick.bind(this);

    this.state = { isFetching: { is: false, id: null } };
  }

  componentWillMount() {
    this.props.actions.getSubmissionsByPage(this.props.admin.submissionsPage);
  }

  componentDidMount() {
    if(!this.props.user.isAdmin) {
      this.context.router.push('/');
    }
  }

  componentWillReceiveProps(nextProps) {
    // Toggles off isFetching when a request is complete.
    if(this.props.contest.isHandlingRequest && !nextProps.contest.isHandlingRequest) {
      this.setState({ isFetching: { is: false, id: null }});
    }
  }

  handleFilterUpdate(label, value) {
    const sortingFilters = [ 'project', 'author', 'date' ];
    if(sortingFilters.indexOf(label.toLowerCase()) !== -1) {
      this.props.actions.setFilters({
        ...this.props.admin.filters,
        project: 'default',
        author: 'default',
        date: 'default',
        [label.toLowerCase()]: value
      });
    } else {
      this.props.actions.setFilters({ ...this.props.admin.filters, [label.toLowerCase()]: value });
    }
  }

  handleActivePhasePromotion() {
    window.confirm('Are you sure you want to advance the timeline?')
     ? this.props.actions.updateActivePhase(parseInt(this.props.contest.activePhase, 10)+1)
     : false;
  }

  handleSubmissionAction(submission) {
    this.props.actions.updateSubmission(submission);
    this.props.actions.toggleIsHandlingRequest(true);
    this.setState({ isFetching: { is: true, id: submission.id }});
  }

  handlePaginationClick(page) {
    this.props.actions.getSubmissionsByPage(page);
  }

  render() {
    const { admin, contest } = this.props;

    const filterKeys = Object.keys(admin.filterOptions);
    const filters = filterKeys.map((key, index) => {
      return <TableFilter key={index}
                          label={key}
                          options={admin.filterOptions[key]}
                          value={admin.filters[key.toLowerCase()]}
                          onChange={this.handleFilterUpdate} />
    });

    const paginationTabCount = Math.ceil(parseInt(contest.totalSubmissions, 10) / 20);
    const paginationButtons = Array.from(new Array(paginationTabCount), (x, i) => {
      return (
        <button
          key={i}
          style={{
            marginRight: '0.5%',
            border: '1px solid #E4E2E2',
            backgroundColor: admin.submissionsPage === i+1 ? '#EDF9FD' : '#F9F9F9' }}
          onClick={this.handlePaginationClick.bind(this, i+1)}>{i+1}
        </button>
      );
    });

    return (
      <div>
        <nav style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', width: '100%', height: 50, borderBottom: '1px solid #e7e7e7', backgroundColor: '#f8f8f8' }}>
          {'Admin links and stuff'}
        </nav>
        <div style={{ padding: '2% 5%', backgroundColor: 'white' }}>
          <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: '2%', borderRadius: 4, backgroundColor: '#DBE5E8' }}>
            <div style={{ display: 'flex', justifyContent: 'center' }}>
              <div style={{ flex: 1, textAlign: 'center' }}>
                <h3>{ contest.activePhase < contest.phases.length-1 ? 'Current Phase' : 'Final Phase' }</h3>
                <p>{contest.phases[contest.activePhase].event}</p>
              </div>
              {
                contest.activePhase < contest.phases.length-1
                  ? (<div style={{ alignSelf: 'center' }}>
                      <div>
                        <button style={{ backgroundColor: 'lightgrey', borderRadius: 4, padding: '8%', border: 'none', whiteSpace: 'nowrap' }}
                                onClick={this.handleActivePhasePromotion}>
                          Promote to next phase
                        </button>
                      </div>
                    </div>)
                  : (null)
              }
              {
                contest.activePhase < contest.phases.length-1
                  ? (<div style={{ flex: 1, textAlign: 'center' }}>
                      <h3>Next Phase</h3>
                      <p>{contest.phases[contest.activePhase+1].event}</p>
                    </div>)
                  : (null)
              }
            </div>
          </div>
          <div style={{ display: 'flex', padding: '2% 0' }}>
            <span style={{ flexBasis: '3%', fontWeight: 'bold' }}>Filters: </span>
            {filters}
          </div>
          <SubmissionsTable submissions={contest.submissions} filters={admin.filters} isFetching={this.state.isFetching} onActionClick={this.handleSubmissionAction} />
          <div style={{ paddingTop: '1%'}}>
            {paginationButtons}
          </div>
        </div>
      </div>
    );
  }
}

Admin.contextTypes = {
  router: () => PropTypes.func
}

Admin.PropTypes = {
  actions: PropTypes.object.isRequired,
  admin: PropTypes.object.isRequired,
  contest: PropTypes.object.isRequired,
  user: PropTypes.object.isRequired
}

function mapStateToProps(state, ownProps) {
  return {
    admin: state.admin,
    contest: state.contest,
    user: state.user
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators({...AdminActions, ...ContestActions}, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Admin);