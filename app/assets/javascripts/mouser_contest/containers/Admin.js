import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as AuthActions from '../actions/auth';
import SubmissionsTable from '../components/SubmissionsTable';
import TableFilter from '../components/TableFilter';

function makeProjects(amount) {
  amount = amount || 5;
  const vendors = [ 'TI', 'Intel', 'NXP', 'ST Micro', 'Cypress', 'Diligent', 'UDOO', 'Seeed Studio' ];
  const authors = [ 'Duder', 'Satan', 'Bowie', 'IndiaGuy', 'OtherDuder' ];
  const projects = [ 'Blinky lights', 'Water gun', 'Moar lights', 'VR porn', 'Drugs' ];

  function random(arr) {
    return arr[Math.floor(Math.random() * arr.length)];
  }

  function randomDate(start, end) {
    return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
  }

  return Array.from(new Array(amount), () => {
    return {
      vendor: random(vendors),
      project: random(projects),
      author: random(authors),
      date: randomDate(new Date(2012, 0, 1), new Date()),
      status: random([ 'undecided', 'approved', 'rejected' ])
    };
  });
}

const subs = makeProjects(30);

class Admin extends Component {
  constructor(props) {
    super(props);

    this.handleFilterUpdate = this.handleFilterUpdate.bind(this);
    this.state = {
      filters: {
        author: 'default',
        date: 'default',
        project: 'default',
        status: 'undecided',
        vendor: 'default',
      }
    };
  }

  handleFilterUpdate(label, value) {
    const sortingFilters = [ 'project', 'author', 'date' ];
    if(sortingFilters.indexOf(label.toLowerCase()) !== -1) {
      this.setState({
        filters: {
          ...this.state.filters,
          project: 'default',
          author: 'default',
          date: 'default',
          [label.toLowerCase()]: value
        }
      });
    } else {
      this.setState({ filters: { ...this.state.filters, [label.toLowerCase()]: value }});
    }

  }

  render() {
    // Title
    // Timeline / Progress slider (input type of range)
    // - has confirm button with a follow up prompt that submits contest changes
    // Dynamic display per timeline.
    //
    // Filters panel
    // Table

    const filterOptions = {
      Vendor: [ 'Cypress', 'Diligent', 'Intel', 'NXP', 'Seeed Studio', 'ST Micro', 'TI', 'UDOO' ],
      Project: [ 'ascending', 'descending' ],
      Author: [ 'ascending', 'descending' ],
      Date: [ 'oldest', 'latest' ],
      Status: [ 'approved', 'rejected', 'undecided' ]
    };

    const filterKeys = Object.keys(filterOptions);
    const filters = filterKeys.map((key, index) => {
      return <TableFilter key={index}
                          label={key}
                          options={filterOptions[key]}
                          value={this.state.filters[key.toLowerCase()]}
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
        <SubmissionsTable submissions={subs} filters={this.state.filters} />
      </div>
    );
  }
}

Admin.PropTypes = {

};

function mapStateToProps(state) {
  return {
    auth: state.auth
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(AuthActions, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Admin);