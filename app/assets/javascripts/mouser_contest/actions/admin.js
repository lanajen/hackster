import { Admin } from '../constants';

export function setFilters(filters) {
  return {
    type: Admin.SET_FILTERS,
    filters
  };
}