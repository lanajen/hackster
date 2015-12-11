# dev needs a different key otherwise it creates conflicts with prod and staging
# which share the same host (hackster.io).
# this is due to keys being stored in the DB for more controlled expiration.
# prod and staging are sharing the same DB, dev has its own, so when a prod/staging
# key is seen by dev it's considered illegal since dev doesn't have it in DB,
# and it resets the session. In turn, prod/staging will consider dev key illegal too.
# outcome: can't comfortably switch from dev to prod without having to constantly
# re-log in.
session_key = ENV['SESSION_KEY'] || '_hackerio_session'
HackerIo::Application.config.session_store :cookie_store, key: session_key, domain: (ENV['FULL_HOST'].present? ? nil : APP_CONFIG['default_domain'])