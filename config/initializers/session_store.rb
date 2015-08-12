# Be sure to restart your server when you modify this file.

HackerIo::Application.config.session_store :active_record_store, key: '_hackerio_session', domain: APP_CONFIG['default_domain']
ActionDispatch::Session::ActiveRecordStore.session_class = Session