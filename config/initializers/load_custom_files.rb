# Heroku Resque auto scaler
require File.join(Rails.root, 'lib/heroku_auto_scale.rb') if Rails.env == 'production'