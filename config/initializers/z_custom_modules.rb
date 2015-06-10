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
require File.join(Rails.root, 'lib/hstore_counter')
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
# heroku domains
require File.join(Rails.root, 'lib/heroku_domains')
# progress tracking for remote file upload
# require File.join(Rails.root, 'lib/carrierwave_uploader_download')
# markdown converter
require File.join(Rails.root, 'lib/markdown_filter')
require File.join(Rails.root, 'lib/single_line_html')
require File.join(Rails.root, 'lib/redcarpet_sociable')
require File.join(Rails.root, 'lib/custom_markdown_renderer')
# attributes with defaults
require File.join(Rails.root, 'lib/has_default')
#notifiable
require File.join Rails.root, 'lib/notifiable'
require File.join Rails.root, 'lib/name_generator'
# hstore columns
require File.join Rails.root, 'lib/hstore_column'
require File.join Rails.root, 'lib/websites_column'
# checklist
require File.join Rails.root, 'lib/checklist'

# require it so that STI works correctly; not necessarily in prod since all classes are preloaded
if Rails.env == 'development'
  require File.join(Rails.root, 'app/models/attachments/sketchfab_file')
  require File.join(Rails.root, 'app/models/attachments/image_file')
  require File.join(Rails.root, 'app/models/attachments/pdf_file')
  require File.join(Rails.root, 'app/models/widgets/cad_file_widget')
  require File.join(Rails.root, 'app/models/widgets/schematic_file_widget')
end