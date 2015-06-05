class MicrosoftChromeSync
  include Singleton
  DEFAULT_LOCALE = 'en'

  @@attributes = :chrome_footer, :chrome_header, :nav, :nav_css

  def self.attributes
    @@attributes
  end

  attributes.each do |attribute|
    define_method attribute do |locale|
      getter attribute, locale
    end

    define_method "#{attribute}=" do |val, locale|
      setter attribute, val, locale
    end
  end

  def attributes locale=DEFAULT_LOCALE
    out = {}
    self.class.attributes.each do |attr|
      out[attr] = send(attr, format_locale(locale))
    end
    out
  end

  def update_attributes attributes={}, locale=DEFAULT_LOCALE
    attributes ||= {}
    attributes = attributes.select{|k,v| k.to_sym.in? self.class.attributes }
    attributes.each do |attr_name, val|
      send "#{attr_name}=", format_locale(locale), val
    end
  end

  private
    def config
      @config ||= YAML.load_file("#{Rails.root}/config/microsoft.yml")[Rails.env]
    end

    def format_locale locale
      loc = locale.try(:[], 0..1)
      loc.present? and loc != DEFAULT_LOCALE ? "#{loc}:" : nil
    end

    def getter attribute, locale
      replace_urls redis.get("#{locale}#{attribute}")
    end

    def redis
      @redis ||= Redis::Namespace.new('ms_chrome', redis: Redis.new($redis_config))
    end

    def replace_urls text
      return unless text

      text.scan(/\{\{([a-z_\.]+)\}\}/).each do |token|
        token = token.first if token.class == Array
        sub = config[token]
        text = text.gsub("{{#{token}}}", sub) if sub
      end
      text
    end

    def setter attribute, locale, val
      if getter(attribute, locale) != val
        redis.set "#{locale}#{attribute}", val
        Cashier.expire "ms_chrome-#{attribute}"
        FastlyRails.purge_by_key 'microsoft'
      end
    end
end