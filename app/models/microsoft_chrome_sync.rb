class MicrosoftChromeSync
  include Singleton

  @@attributes = :chrome_footer, :chrome_header, :nav, :nav_css

  def self.attributes
    @@attributes
  end

  attributes.each do |attribute|
    define_method attribute do
      getter attribute
    end

    define_method "#{attribute}=" do |val|
      setter attribute, val
    end
  end

  def attributes
    out = {}
    self.class.attributes.each do |attr|
      out[attr] = send(attr)
    end
    out
  end

  def update_attributes attributes={}
    attributes ||= {}
    attributes = attributes.select{|k,v| k.to_sym.in? self.class.attributes }
    attributes.each do |attr_name, val|
      send "#{attr_name}=", val
    end
  end

  private
    def config
      @config ||= YAML.load_file("#{Rails.root}/config/microsoft.yml")[Rails.env]
    end

    def getter attribute
      replace_urls redis.get(attribute)
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

    def setter attribute, val
      if getter(attribute) != val
        redis.set attribute, val
        Cashier.expire "ms_chrome-#{attribute}"
      end
    end
end