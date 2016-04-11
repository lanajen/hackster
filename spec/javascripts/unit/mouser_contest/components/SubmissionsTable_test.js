import React from 'react';
import expect from 'expect';
import { inspect } from 'util';
import { createRenderer, findAllInRenderedTree, renderIntoDocument } from 'react-addons-test-utils';

import SubmissionsTable from 'mouser_contest/components/SubmissionsTable';
import TableRow from 'mouser_contest/components/TableRow';

function buildProjects(amount) {
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

function getInitialState(subs, normalStatusBehavior) {
  subs = subs || [];
  return {
    filters: {
      author: 'default',
      date: 'default',
      project: 'default',
      status: normalStatusBehavior ? 'undecided' : 'default',
      vendor: 'default',
    },
    filterOptions: {
      Vendor: [ 'Cypress', 'Diligent', 'Intel', 'NXP', 'Seeed Studio', 'ST Micro', 'TI', 'UDOO' ],
      Project: [ 'ascending', 'descending' ],
      Author: [ 'ascending', 'descending' ],
      Date: [ 'oldest', 'latest' ],
      Status: [ 'approved', 'rejected', 'undecided' ]
    },
    submissions: subs
  };
}

function setupShallow(props) {
  let renderer = createRenderer();
  renderer.render(<SubmissionsTable submissions={props.submissions} filters={props.filters} />);
  let output = renderer.getRenderOutput();

  return { renderer, output, props };
}

function sortByDirection(list, direction) {
  return list.sort((a, b) => {
    if(direction === 'forward' || direction === 'oldest') {
      if(a < b) return -1;
      if(a > b) return 1;
      return 0;
    } else {
      if(a > b) return -1;
      if(a < b) return 1;
      return 0;
    }
  });
}

describe('SubmissionsTable', () => {

  it('should render a header TableRow as a first child', () => {
    const subs = buildProjects(3);
    const { renderer, output, props } = setupShallow(getInitialState(subs, false));

    expect(output.props.children[0].props.header).toBe(true);
  });

  it('should render n number of rows as children', () => {
    const subs = buildProjects(3);
    const { renderer, output, props } = setupShallow(getInitialState(subs, false));

    expect(React.Children.count(output.props.children[1])).toBe(subs.length);
  });

  it('should initially render submissions with a status of undecided', () => {
    let foundUndecided = false;
    const subs = buildProjects(3)
      .map((sub, index, list) => {
        if(sub.status === 'undecided') foundUndecided = true;
        if(index === list.length-1 && !foundUndecided) sub.status = 'undecided';
        return sub;
      });

    const undecidedCount = subs.reduce((acc, sub) => {
      if(sub.status === 'undecided') acc++;
      return acc;
    }, 0);

    const { output } = setupShallow(getInitialState(subs, true));

    expect(React.Children.count(output.props.children[1])).toBe(undecidedCount);
  });

  it('should render submissions with a status of approved', () => {
    let foundApproved = false;
    const subs = buildProjects(5)
      .map((sub, index, list) => {
        if(sub.status === 'approved') foundApproved = true;
        if(index === list.length-1 && !foundApproved) sub.status = 'approved';
        return sub;
      });

    const approvedCount = subs.reduce((acc, sub) => {
      if(sub.status === 'approved') acc++;
      return acc;
    }, 0);

    let initState = getInitialState(subs, false);
    initState.filters.status = 'approved';

    const { output } = setupShallow(initState);

    expect(React.Children.count(output.props.children[1])).toBe(approvedCount);
  });

  it('should render submissions with a status of rejected', () => {
    let foundRejected = false;
    const subs = buildProjects(5)
      .map((sub, index, list) => {
        if(sub.status === 'rejected') foundRejected = true;
        if(index === list.length-1 && !foundRejected) sub.status = 'rejected';
        return sub;
      });

    const rejectedCount = subs.reduce((acc, sub) => {
      if(sub.status === 'rejected') acc++;
      return acc;
    }, 0);

    let initState = getInitialState(subs, false);
    initState.filters.status = 'rejected';

    const { output } = setupShallow(initState);

    expect(React.Children.count(output.props.children[1])).toBe(rejectedCount);
  });

  it('should render submissions of a vendor name only', () => {

    function renderVendorByName(vendorName) {
      let vendorNamesCount = 0;

      // Makes sure theres atleast one submission with the supplied vendorName.
      // Counts the amount of vendors by vendorName built.
      const subs = buildProjects(20)
        .map((sub, index, list) => {
          if(index === list.length-1 && vendorNamesCount === 0) {
            sub.vendor = vendorName;
            vendorNamesCount++;
          } else if(sub.vendor === vendorName) {
            vendorNamesCount++;
          }
          return sub;
        });

      let initState = getInitialState(subs, false);
      initState.filters.vendor = vendorName;

      const { output } = setupShallow(initState);
      const vendors = React.Children.map(output.props.children[1], child => child.props.rowData.vendor);

      return { vendorNamesCount, vendors };
    }

    const cypress = renderVendorByName('Cypress');
    const intel = renderVendorByName('Intel');

    expect(cypress.vendorNamesCount).toBe(cypress.vendors.length);
    expect(intel.vendorNamesCount).toBe(intel.vendors.length);
  });

  it('should render authors alphabetically ascending', () => {
    const subs = buildProjects(5);
    const sortedAuthorList = sortByDirection(subs.map(sub => sub.author), 'forward');

    let initState = getInitialState(subs, false);
    initState.filters.author = 'ascending';

    const { output } = setupShallow(initState);
    const authors = React.Children.map(output.props.children[1], child => child.props.rowData.author);

    expect(sortedAuthorList).toEqual(authors);
  });

  it('should render authors alphabetically descending', () => {
    const subs = buildProjects(5);
    const sortedAuthorList = sortByDirection(subs.map(sub => sub.author), 'backward');

    let initState = getInitialState(subs, false);
    initState.filters.author = 'descending';

    const { output } = setupShallow(initState);
    const authors = React.Children.map(output.props.children[1], child => child.props.rowData.author);

    expect(sortedAuthorList).toEqual(authors);
  });

  it('should render by the latest date first', () => {
    const subs = buildProjects(5);
    const sortedDateList = sortByDirection(subs.map(sub => sub.date), 'latest');

    let initState = getInitialState(subs, false);
    initState.filters.date = 'latest';

    const { output } = setupShallow(initState);
    const dates = React.Children.map(output.props.children[1], child => child.props.rowData.date);

    expect(sortedDateList).toEqual(dates);
  });

  it('should render by the oldeset date first', () => {
    const subs = buildProjects(5);
    const sortedDateList = sortByDirection(subs.map(sub => sub.date), 'oldest');

    let initState = getInitialState(subs, false);
    initState.filters.date = 'oldest';

    const { output } = setupShallow(initState);
    const dates = React.Children.map(output.props.children[1], child => child.props.rowData.date);

    expect(sortedDateList).toEqual(dates);
  });

  it('should sort by projects alphabetically ascending', () => {
    const subs = buildProjects(5);
    const sortedProjectList = sortByDirection(subs.map(sub => sub.project), 'forward');

    let initState = getInitialState(subs, false);
    initState.filters.project = 'ascending';

    const { output } = setupShallow(initState);
    const projects = React.Children.map(output.props.children[1], child => child.props.rowData.project);


    expect(sortedProjectList).toEqual(projects);
  });

  it('should sort by projects alphabetically descending', () => {
    const subs = buildProjects(5);
    const sortedProjectList = sortByDirection(subs.map(sub => sub.project), 'backward');

    let initState = getInitialState(subs, false);
    initState.filters.project = 'descending';

    const { output } = setupShallow(initState);
    const projects = React.Children.map(output.props.children[1], child => child.props.rowData.project);


    expect(sortedProjectList).toEqual(projects);
  });
});





