import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as AdminActions from '../actions/admin';
import * as AuthActions from '../actions/auth';
import * as ContestActions from '../actions/contest';

import SubmissionsTable from '../components/SubmissionsTable';
import TableFilter from '../components/TableFilter';

class Admin extends Component {
  constructor(props) {
    super(props);

    this.handleFilterUpdate = this.handleFilterUpdate.bind(this);
    this.handleActivePhasePromotion = this.handleActivePhasePromotion.bind(this);
  }

  componentWillMount() {
    this.props.actions.getSubmissions();
  }

  componentDidMount() {
    if(!this.props.user.isAdmin) {
      this.props.actions.redirectToLogin(this.context.router);
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
    this.props.actions.updateActivePhase(parseInt(this.props.contest.activePhase, 10)+1)
    // window.confirm('Are you sure you want to advance the timeline?')
    //  ? this.props.actions.updateActivePhase(parseInt(this.props.contest.activePhase, 10)+1)
    //  : false;
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
            { filters }
          </div>
          <SubmissionsTable submissions={contest.submissions} filters={admin.filters} onActionClick={this.props.actions.updateSubmission} />
        </div>
      </div>
    );
  }
}

Admin.contextTypes = {
  router: () => PropTypes.func
};

Admin.PropTypes = {
  actions: PropTypes.object.isRequired,
  admin: PropTypes.object.isRequired,
  auth: PropTypes.object.isRequired,
  contest: PropTypes.object.isRequired,
  user: PropTypes.object.isRequired
};

function mapStateToProps(state, ownProps) {
  return {
    admin: state.admin,
    auth: state.auth,
    contest: state.contest,
    user: state.user
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators({...AdminActions, ...AuthActions, ...ContestActions}, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Admin);