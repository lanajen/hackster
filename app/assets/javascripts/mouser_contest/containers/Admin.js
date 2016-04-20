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

    const rangeStyle = {
      boxSizing: 'border-box',
      display: 'block',
      width: '100%',
      margin: '20px 0',
      cursor: 'pointer',
      backgroundColor: 'lightblue',
      backgroundClip: 'content-box',
      height: 6,
      borderRadius: 999,
      WebkitAppearance: 'none',
      appearance: 'none'
    }

    return (
      <div>
        <nav style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', width: '100%', height: 50, borderBottom: '1px solid #e7e7e7', backgroundColor: '#f8f8f8' }}>
          {'Admin links and stuff'}
        </nav>
        <div style={{ padding: '2% 5%', backgroundColor: 'white' }}>
          <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
            <div>Timeline</div>
            <div>
              <h3>Current Phase</h3>
              <p>{contest.phases[contest.activePhase].event}</p>
            </div>
            <div></div>
          </div>
          <div style={{ display: 'flex', padding: '2% 0' }}>
            <span style={{ flex: '0.1', fontWeight: 'bold' }}>Filters: </span>
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