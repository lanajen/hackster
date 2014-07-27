# Youtube API wrapper
require File.join(Rails.root, 'lib/youtube/init')
# Heroku Resque auto scaler
require File.join(Rails.root, 'lib/sidekiq_autoscale.rb') if Rails.env == 'staging'
# Taggable
require File.join(Rails.root, 'lib/taggable')
# Privatable
require File.join(Rails.root, 'lib/privatable')
# Broadcastable
require File.join(Rails.root, 'lib/base_broadcast_observer')

require File.join(Rails.root, 'lib/string_parser')

require File.join(Rails.root, 'lib/counter')

require File.join(Rails.root, 'lib/tableless_association')
# turn off asset messages in logger
require File.join(Rails.root, 'lib/quiet_assets')
# roles
require File.join(Rails.root, 'lib/roles')

require File.join(Rails.root, 'lib/route_constraints')
# after_commit_callbacks
require File.join(Rails.root, 'lib/after_commit_callbacks')