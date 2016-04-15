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
    SET_PHASES: null
  }),

  User: keymirror({
    SET_PROJECTS: null,
    SET_SUBMISSION: null,
    SUBMIT_PROJECTS: null,
    SET_ADMIN: null
  }),

  Vendors: keymirror({
    SET_VENDORS: null
  })
}