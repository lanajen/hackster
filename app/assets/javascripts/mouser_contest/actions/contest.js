import moment from 'moment';

import { Contest } from '../constants';
import { setSubmissionsPage } from './admin';
import { setVendors } from './vendors';
import { setUserData, getProjects } from './user';

import { fetchSubmissionsByPage, postActivePhase, updateSubmissionStatus } from '../requests';

export function setInitialData(props) {
  const { activePhase, currentUser, phases, signoutUrl, vendors } = props;

  return dispatch => {
    // Contest
    dispatch(setActivePhase(parseInt(activePhase, 10)));
    dispatch(setSignoutUrl(signoutUrl));
    dispatch(setPhases(
      [].slice.call(phases).map(phase => {
        phase.date = moment(phase.date, 'DD-MM-YYYY').format('MMMM Do');
        return phase;
      })
    ));
    //User
    dispatch(setUserData(currentUser));
    dispatch(getProjects(currentUser.id));
    //Vendors
    dispatch(setVendors(vendors));
  };
}

export function updateActivePhase(phase) {
  phase = phase > 7 ? 7 : phase;

  return dispatch => {
    return postActivePhase(phase)
      .then(res => {
        dispatch(setActivePhase(phase));
      })
      .catch(err => console.error('postActivePhase Error: ', err));
  };
}

export function setActivePhase(activePhase) {
  return {
    type: Contest.SET_ACTIVE_PHASE,
    activePhase
  };
}

function setPhases(phases) {
  return {
    type: Contest.SET_CONTEST_PHASES,
    phases
  };
}

function setSubmissions(submissions, total) {
  return {
    type: Contest.SET_CONTEST_SUBMISSIONS,
    submissions,
    total
  };
}

function setSubmission(submission) {
  return {
    type: Contest.SET_CONTEST_SUBMISSION,
    submission
  };
}

export function getSubmissionsByPage(page) {
  return dispatch => {
    return fetchSubmissionsByPage(page)
      .then(subData => {
        dispatch(setSubmissionsPage(page));
        dispatch(setSubmissions(subData.submissions, subData.total));
      })
      .catch(err => console.error('getSubmissions Error: ', err));
  };
}

export function updateSubmission(submission) {
  return dispatch => {
    return updateSubmissionStatus(submission)
      .then(res => {
        dispatch(setSubmission(submission));
        dispatch(toggleIsHandlingRequest(false));
      })
      .catch(err => console.error('updateSubmissionStatus Error ', err));
  };
}

export function toggleIsHandlingRequest(bool) {
  return {
    type: Contest.TOGGLE_IS_HANDLING_REQUEST,
    bool
  };
}

export function toggleMessenger(messenger) {
  return {
    type: Contest.TOGGLE_MESSENGER,
    messenger
  };
}

function setSignoutUrl(signoutUrl) {
  return {
    type: Contest.SET_SIGNOUT_URL,
    signoutUrl
  }
}
