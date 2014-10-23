# Youtube API wrapper
require File.join(Rails.root, 'lib/youtube/init')
# Heroku Resque auto scaler
# require File.join(Rails.root, 'lib/sidekiq_autoscaler.rb') if Rails.env == 'staging'
# Taggable
require File.join(Rails.root, 'lib/taggable')
# Privatable
require File.join(Rails.root, 'lib/privatable')
# Broadcastable
require File.join(Rails.root, 'lib/base_broadcast_observer')
# parse strings into int and bool
require File.join(Rails.root, 'lib/string_parser')
# cached counters
require File.join(Rails.root, 'lib/counter')
# virtual associations stored in a model's column
require File.join(Rails.root, 'lib/tableless_association')
# turn off asset messages in logger
require File.join(Rails.root, 'lib/quiet_assets')
# roles
require File.join(Rails.root, 'lib/roles')
# route constraints
require File.join(Rails.root, 'lib/route_constraints')
# after_commit_callbacks
require File.join(Rails.root, 'lib/after_commit_callbacks')
# make attr_was and attr_changed? work for attrs created using store method
require File.join(Rails.root, 'lib/set_changes_for_stored_attributes')
# common tire init stuff
require File.join(Rails.root, 'lib/tire_initialization')
# editable slug/user_name
require File.join(Rails.root, 'lib/editable_slug')