class MicrosoftChromeSync
  include Singleton

  @@attributes = :chrome_footer, :chrome_header, :nav

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
    def getter attribute
      redis.get(attribute)
    end

    def redis
      @redis ||= Redis::Namespace.new('ms_chrome', redis: Redis.new($redis_config))
    end

    def setter attribute, val
      redis.set attribute, val
      Cashier.expire "ms_chrome-#{attribute}"
    end
end