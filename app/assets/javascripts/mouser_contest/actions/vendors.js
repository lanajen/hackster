import { Vendors } from '../constants';

export function setVendors(vendors) {
  return {
    type: Vendors.SET_VENDORS,
    vendors
  };
}