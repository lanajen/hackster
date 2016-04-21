import keymirror from 'keymirror';

export default {
  Admin: keymirror({
    SET_FILTERS: null,
    SET_SUBMISSIONS: null
  }),

  Auth: keymirror({
    SET_AUTHORIZED: null
  }),

  Contest: keymirror({
    SET_ACTIVE_PHASE: null,
    SET_PHASES: null,
    SET_SUBMISSIONS: null,
    SET_SUBMISSION: null,
    TOGGLE_MESSENGER: null
  }),

  User: keymirror({
    SET_ADMIN: null,
    SET_PROJECTS: null,
    SET_SUBMISSION: null,
    SET_USER: null,
    SUBMIT_PROJECTS: null
  }),

  Vendors: keymirror({
    SET_VENDORS: null
  })
}