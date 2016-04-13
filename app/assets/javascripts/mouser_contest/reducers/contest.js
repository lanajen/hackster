import { Contest } from '../constants';

const phases = [
  {date: 'May 1st', event: 'Project submissions open'},
  {date: 'May 15th', event: 'Project submissions close', sub_action: 'Prelimenary voting begins'},
  {date: 'May 31st', event: 'Project voting ends', sub_action: 'Vendor champions chosen'},
  {date: 'June 1st', event: 'Round 1 begins'},
  {date: 'June 10th', event: 'Round 2 begins'},
  {date: 'June 20th', event: 'Round 3 begins'},
  {date: 'June 30th', event: 'Competition ends', sub_action: 'Winner announced'}
];

const initialState = {
  phase: '',
  phases: phases,
  user: {}
};

export default function platforms(state = initialState, action) {
  switch(action.type) {
    case Contest.SET_PHASE:
      return { ...state, phase: action.phase };

    default:
      return state;
  }
}