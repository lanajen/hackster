# Youtube API wrapper
require File.join(Rails.root, 'lib/youtube/init')
# Taggable
require File.join(Rails.root, 'lib/taggable')
# Privatable
require File.join(Rails.root, 'lib/privatable')
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
require File.join(Rails.root, 'lib/algolia_search_helpers')
# editable slug/user_name
require File.join(Rails.root, 'lib/editable_slug')
# heroku domains
require File.join(Rails.root, 'lib/heroku_domains')
# progress tracking for remote file upload
# require File.join(Rails.root, 'lib/carrierwave_uploader_download')
# markdown converter
require File.join(Rails.root, 'lib/markdown_filter')
require File.join(Rails.root, 'lib/single_line_html')
require File.join(Rails.root, 'lib/redcarpet_hackster')
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
# ActionDispatch::Request override
require File.join Rails.root, 'lib/action_dispatch_request'
# active record extension
require File.join Rails.root, 'lib/active_record_extension'
# add ability / cancan to models
require File.join Rails.root, 'lib/has_ability'
# AR destroy async
require File.join Rails.root, 'lib/active_record_destroy_async'

require File.join Rails.root, 'lib/omniauth_doorkeeper'

require File.join Rails.root, 'lib/mixpanel_methods'
