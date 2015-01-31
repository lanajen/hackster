# Be sure to restart your server when you modify this file.

HackerIo::Application.config.session_store :cookie_store, key: '_hackerio_session', domain: APP_CONFIG['default_domain']

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# HackerIo::Application.config.session_store :active_record_store
