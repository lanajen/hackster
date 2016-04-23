import keymirror from 'keymirror';

export default {
  Admin: keymirror({
    SET_ADMIN_FILTERS: null,
    SET_ADMIN_SUBMISSIONS_PAGE: null
  }),

  Contest: keymirror({
    SET_ACTIVE_PHASE: null,
    SET_CONTEST_PHASES: null,
    SET_CONTEST_SUBMISSIONS: null,
    SET_CONTEST_SUBMISSION: null,
    TOGGLE_IS_HANDLING_REQUEST: null,
    TOGGLE_MESSENGER: null
  }),

  User: keymirror({
    SET_USER_PROJECTS: null,
    SET_USER_SUBMISSIONS: null,
    SET_USER_DATA: null
  }),

  Vendors: keymirror({
    SET_VENDORS: null
  })
}