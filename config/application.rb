require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(:default, Rails.env)
end

require File.expand_path('../redis', __FILE__)

module HackerIo
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += Dir[ config.root.join('app', 'models', '**/') ]
    config.autoload_paths += Dir[ config.root.join('app', 'serializers', '**/') ]
    config.autoload_paths += Dir[ config.root.join('app', 'middlewares', '**/') ]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    config.active_record.observers = :project_observer, :widget_observer,
      :user_observer, :comment_observer, :respect_observer, :tag_observer,
      :member_observer, :team_observer, :follow_relation_observer,
      :issue_observer, :build_log_observer, :assignment_observer,
      :platform_observer, :project_collection_observer, :attachment_observer,
      :challenge_entry_observer, :challenge_observer, :awarded_badge_observer,
      :list_observer, :receipt_observer, :part_join_observer, :event_observer,
      :notification_observer, :part_observer, :thought_observer,
      :blog_post_observer, :impression_observer, :conversation_observer,
      :order_observer, :order_line_observer, :address_observer,
      :payment_observer, :prize_observer, :challenge_registration_observer,
      :challenge_idea_observer, :faq_entry_observer,
      :product_observer, :external_project_observer,
      :review_decision_observer, :review_thread_observer,
      :sponsor_relation_observer, :meetup_event_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true
    config.i18n.available_locales = [:en, :zh, :'en-US', :'zh-CN']

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.


    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    config.assets.precompile += %w( admin.css email.css bitbucket-widget.min.css bitbucket-widget.min.js slick.eot slick.svg slick.ttf slick.woff datepicker.js datepicker.css tinymce.js tinymce/plugins/link/plugin.js tinymce/plugins/paste/plugin.js tinymce/plugins/media/plugin.js tinymce/plugins/code/plugin.js gmaps/google.js follow_iframe.css follow_iframe.js project-thumb.css channel.js whitelabel/mediateklabs/min.css whitelabel/mediateklabs/min.js whitelabel/chip/application.css whitelabel/arduino/application.css live.js mouser/style.css mouser.js )

    config.active_record.whitelist_attributes = false

    # Enable the asset pipeline
    config.assets.enabled = true

    config.active_record.raise_in_transactional_callbacks = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    config.assets.paths << Rails.root.join('vendor', 'assets', 'fonts')
    config.assets.paths << Rails.root.join('vendor', 'assets', 'images')
    config.assets.precompile += %w(.svg .eot .woff .ttf)

    if ENV['ASSET_HOST_URL'].present?
      config.action_controller.asset_host = ENV['ASSET_HOST_URL']
    end

    config.assets.initialize_on_precompile = true

    config.logger = Logger.new(STDOUT)

    config.action_mailer.delivery_method = :mailgun
    config.action_mailer.mailgun_settings = {
      domain: ENV['MAILGUN_DOMAIN'],
    }

    config.middleware.use Rack::Attack

    # cashier tag caching
    config.cashier.adapter = :redis_store
    config.cashier.adapter.redis = RedisConn.conn

    config.middleware.use "SetCookieDomain", (ENV['FULL_HOST'].present? ? nil : ENV['DEFAULT_DOMAIN'])

    allowed_origins = []
    if ENV['DEFAULT_DOMAIN']
      default_host_regexp = Regexp.new(".+\.#{ENV['DEFAULT_DOMAIN']}")
      allowed_origins << default_host_regexp
    end
    allowed_origins += ENV['ASSET_ORIGINS'].split(/,/) if ENV['ASSET_ORIGINS']
    if allowed_origins.any?
      config.middleware.insert_before ActionDispatch::Static, "Rack::Cors", debug: ENV['LOG_LEVEL'] == 'debug', logger: (-> { Rails.logger }) do
        allow do
          origins *allowed_origins
          resource '/assets/*', headers: :any, methods: :get
        end
      end
    end
  end
end