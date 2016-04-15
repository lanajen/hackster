import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as AdminActions from '../actions/admin';
import * as AuthActions from '../actions/auth';

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
    const { admin } = this.props;
    console.log('FROM ADMIN', admin)
    console.log('FROM ADMIN', this.props)
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
      <div style={{ padding: '2% 5%'}}>
        {'Admin Page'}
        <div>
          <div style={{ textAlign: 'center'}}>Timeline</div>
          <input className="slider_input" style={rangeStyle} type="range" min={0} max={100} step={25} list="steplist" />
          <div style={{ display: 'flex' }}>
            <span style={{ flex: 1 }}>Submissions Open</span>
            <span style={{ flex: 1 }}>Submissions Closed</span>
            <span style={{ flex: 1 }}>Prelim Voting</span>
            <span style={{ flex: 1 }}>Voting Closed</span>
            <span>Move to next</span>
          </div>
          <datalist id="steplist">
            <option></option>
            <option></option>
            <option></option>
            <option></option>
            <option></option>
          </datalist>
        </div>
        <div style={{ display: 'flex', padding: '2% 0' }}>
          <span style={{ flex: '0.1', fontWeight: 'bold' }}>Filters: </span>
          { filters }
        </div>
        <SubmissionsTable submissions={admin.submissions} filters={admin.filters} />
      </div>
    );
  }
}

Admin.PropTypes = {
  actions: PropTypes.object.isRequired,
  admin: PropTypes.object.isRequired,
  auth: PropTypes.object.isRequired
};

function mapStateToProps(state) {
  return {
    admin: state.admin,
    auth: state.auth
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators({...AdminActions, ...AuthActions}, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Admin);