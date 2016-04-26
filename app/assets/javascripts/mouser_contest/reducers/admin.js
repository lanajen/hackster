import { Admin } from '../constants';

const initialState = {
  filters: {
    author: 'default',
    date: 'default',
    project: 'default',
    status: 'default',
    vendor: 'default',
  },
  filterOptions: {
    Vendor: [ 'Cypress', 'Digilent', 'Intel', 'NXP', 'Seeed Studio', 'ST Microelectronics', 'Texas Instruments', 'Udoo' ],
    Project: [ 'ascending', 'descending' ],
    Author: [ 'ascending', 'descending' ],
    Date: [ 'oldest', 'latest' ],
    Status: [ 'approved', 'rejected' ]
  },
  submissionsPage: 1
}

export default function admin(state = initialState, action) {
  switch(action.type) {
    case Admin.SET_ADMIN_FILTERS:
      return { ...state, filters: action.filters };

    case Admin.SET_ADMIN_SUBMISSIONS_PAGE:
      return { ...state, submissionsPage: action.page };

    default:
      return state;
  }
}