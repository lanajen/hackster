import { Vendors } from '../constants';

export default function platforms(state = [], action) {
  switch(action.type) {

    case Vendors.SET_VENDORS:
      return action.vendors;

    default:
      return state;
  }
}