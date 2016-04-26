import { Contest } from '../constants';

/**
  PHASES:
  [
    {date: 'May 1st', event: 'Project submissions open'},
    {date: 'May 15th', event: 'Project submissions close', sub_event: 'Prelimenary voting begins'},
    {date: 'May 15th', event: 'Prelimenary voting begins'},
    {date: 'May 31st', event: 'Project voting ends', sub_event: 'Vendor champions chosen'},
    {date: 'June 1st', event: 'Round 1 begins'},
    {date: 'June 10th', event: 'Round 2 begins'},
    {date: 'June 20th', event: 'Round 3 begins'},
    {date: 'June 30th', event: 'Competition ends', sub_event: 'Winner announced'}
  ]
*/

const initialState = {
  activePhase: 0,
  isHandlingRequest: false,
  messenger: { open: false, msg: '', type: 'error' },
  phase: '',
  phases: [],
  signoutUrl: '',
  submissions: [],
  totalSubmissions: 0
}

export default function platforms(state = initialState, action) {
  switch(action.type) {
    case Contest.SET_ACTIVE_PHASE:
      return { ...state, activePhase: action.activePhase };

    case Contest.SET_CONTEST_PHASES:
      return { ...state, phases: action.phases };

    case Contest.SET_CONTEST_SUBMISSION:
      console.log("UPDATING", action.submission);
      const updateSubmissions = state.submissions.map(sub => {
        return action.submission.id === sub.id ? { ...sub, ...action.submission } : sub;
      });
      return { ...state, submissions: updateSubmissions };

    case Contest.SET_SIGNOUT_URL:
      return { ...state, signoutUrl: action.signoutUrl };

    case Contest.SET_CONTEST_SUBMISSIONS:
      return { ...state, submissions: action.submissions, totalSubmissions: action.total };

    case Contest.TOGGLE_IS_HANDLING_REQUEST:
      return { ...state, isHandlingRequest: action.bool };

    case Contest.TOGGLE_MESSENGER:
      return { ...state, messenger: action.messenger };

    default:
      return state;
  }
}