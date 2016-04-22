import moment from 'moment';

import { Contest } from '../constants';
import { setVendors } from './vendors';

import { fetchSubmissions } from '../requests';

function makeSubmissions(amount) {
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
      id: Math.floor(Math.random() * 100000),
      author: random(authors),
      date: randomDate(new Date(2012, 0, 1), new Date()),
      project: random(projects),
      status: random([ 'undecided', 'approved', 'rejected' ]),
      vendor: random(vendors)
    };
  });
}

function setSubmissions(submissions) {
  return {
    type: Contest.SET_SUBMISSIONS,
    submissions
  }
}

function setSubmission(submission) {
  return {
    type: Contest.SET_SUBMISSION,
    submission
  }
}

export function getSubmissions() {
  return dispatch => {
    dispatch(setSubmissions(makeSubmissions(30)));
    // return fetchSubmissions()
    //   .then(subs => {
    //     dispatch(setSubmissions(subs));
    //   })
    //   .catch(err => console.error('getSubmissions Error: ', err));
  }
}

export function updateSubmission(submission) {
  return dispatch => {
    // Make the request, on 200 update the store.
    dispatch(setSubmission(submission));
  }
}

export function setActivePhase(phase) {
  return {
    type: Contest.SET_ACTIVE_PHASE,
    phase
  }
}

function setPhases(phases) {
  return {
    type: Contest.SET_PHASES,
    phases
  }
}

export function setInitialData(props) {
  const { activePhase, phases, vendors } = props;

  return dispatch => {
    dispatch(setActivePhase(parseInt(activePhase, 10)));
    dispatch(setVendors(vendors));
    dispatch(setPhases(
      [].slice.call(phases).map(phase => {
        phase.date = moment(phase.date, 'DD-MM-YYYY').format('MMMM Do');
        return phase;
      })
    ));
  }
}