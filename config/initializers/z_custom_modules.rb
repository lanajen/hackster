# Youtube API wrapper
require File.join(Rails.root, 'lib/youtube/init')
# Heroku Resque auto scaler
require File.join(Rails.root, 'lib/heroku_auto_scale.rb') if Rails.env == 'production'
# Taggable
require File.join(Rails.root, 'lib/taggable')
# Privatable
require File.join(Rails.root, 'lib/privatable')
# Broadcastable
require File.join(Rails.root, 'lib/broadcast_observer')