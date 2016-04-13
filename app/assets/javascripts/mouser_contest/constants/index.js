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
    SET_PHASE: null
  }),

  Platforms: keymirror({
    SET_STATE: null
  })
}