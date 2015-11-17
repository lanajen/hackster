module ChromeSync
  class Base
    def attributes locale=nil
      @resolver.attributes locale
    end

    def initialize platform
      config = global_config[platform]
      @resolver = "ChromeSync::Resolver::#{platform.camelize}".constantize.new(platform, config)

      config['attributes'].each do |attribute|
        self.class.send :define_method, attribute do |locale=nil|
          @resolver.getter attribute, locale
        end

        self.class.send :define_method, "#{attribute}=" do |val, locale=nil|
          @resolver.setter attribute, val, locale
        end
      end
    end

    def update_attributes attributes={}, locale=nil
      @resolver.update_attributes attributes, locale
    end

    private
      def global_config
        YAML.load_file File.join(Rails.root, 'config/chrome_sync.yml')
      end
  end

  module Resolver
    class Base
      def attributes locale
        locale ||= default_locale
        out = {}
        config['attributes'].each do |attr|
          out[attr] = getter(attr, locale)
        end
        out
      end

      def getter attribute, locale
        locale ||= default_locale
        redis.get i18n_attribute(attribute, locale)
      end

      def initialize platform, config
        @platform = platform
        @config = config
      end

      def setter attribute, locale, val
        locale ||= default_locale
        if getter(attribute, locale) != val
          redis.set i18n_attribute(attribute, locale), val
          Cashier.expire cache_key(attribute, locale)
          # has memcache cache expired when we send the request to fastly?
          FastlyRails.purge_by_key @platform
        end
      end

      def update_attributes attributes, locale
        attributes ||= {}
        locale ||= default_locale
        attributes = attributes.select{|k,v| k.to_sym.in? config['attributes'] }
        attributes.each do |attr_name, val|
          setter attr_name, locale, val
        end
      end

      private
        def cache_key attribute, locale
          locale ||= default_locale
          "#{config['prefix']}-#{locale}:#{attribute}"
        end

        def config
          @config
        end

        def default_locale
          config['default_locale']
        end

        def format_locale locale
          locale.present? and locale.to_s != default_locale ? "#{locale}:" : nil
        end

        def i18n_attribute attribute, locale
          "#{format_locale(locale)}#{attribute}"
        end

        def redis
          @redis ||= Redis::Namespace.new(config['prefix'], redis: RedisConn.conn)
        end
    end
  end
end