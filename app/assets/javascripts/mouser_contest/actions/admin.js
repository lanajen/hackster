import { Admin } from '../constants';

export function setFilters(filters) {
  return {
    type: Admin.SET_ADMIN_FILTERS,
    filters
  };
}

export function setSubmissionsPage(page) {
  return {
    type: Admin.SET_ADMIN_SUBMISSIONS_PAGE,
    page
  };
}