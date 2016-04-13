import { Admin } from '../constants';

const initialState = {
  filters: {
    author: 'default',
    date: 'default',
    project: 'default',
    status: 'undecided',
    vendor: 'default',
  },
  filterOptions: {
    Vendor: [ 'Cypress', 'Digilent', 'Intel', 'NXP', 'Seeed Studio', 'ST Micro', 'TI', 'UDOO' ],
    Project: [ 'ascending', 'descending' ],
    Author: [ 'ascending', 'descending' ],
    Date: [ 'oldest', 'latest' ],
    Status: [ 'approved', 'rejected', 'undecided' ]
  },
  submissions: []
};

export default function admin(state = initialState, action) {
  switch(action.type) {
    case Admin.SET_FILTERS:
      return { ...state, filters: action.filters };

    case Admin.SET_SUBMISSIONS:
      return { ...state, submissions: action.submissions };

    default:
      return state;
  }
}