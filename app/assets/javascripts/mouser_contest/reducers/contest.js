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
  phases: [],
  submissions: []
};

export default function platforms(state = initialState, action) {
  switch(action.type) {
    case Contest.SET_ACTIVE_PHASE:
      return { ...state, activePhase: action.phase };

    case Contest.SET_PHASES:
      return { ...state, phases: action.phases };

    case Contest.SET_SUBMISSION:
      return { ...state, submissions: state.submissions.map(sub => {
        return action.submission.id === sub.id ? action.submission : sub;
      })};

    case Contest.SET_SUBMISSIONS:
      return { ...state, submissions: action.submissions };

    default:
      return state;
  }
}