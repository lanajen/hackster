class SparkfunPart < SparkfunResource
  RESOURCE_ENDPOINT = '/products'
  SPARKFUN_PLATFORM_ID = 2858

  attr_reader :hackster_part

  def fetch
    if sparkfun_json
      sparkfun_json.each do |key, val|
        instance_variable_set "@#{key}", val
      end
      if sparkfun_original
        build_part(platform_id: SPARKFUN_PLATFORM_ID, mpn: id, private: true, should_generate_slug: true)
      else
        build_part
      end
    end
  end

  def find_or_fetch
    @hackster_part = (Part.where(platform_id: SPARKFUN_PLATFORM_ID, mpn: id).first || fetch)
  end

  def initialize id
    @id = id
    find_or_fetch
  end

  def method_missing method_name, *args
    if instance_variable_defined? "@#{method_name}"
      instance_variable_get "@#{method_name}"
    else
      super
    end
  end

  private
    def build_part extra_attributes={}
      attributes = {
        name: name,
        store_link: url,
        description: description,
        unit_price: price,
        tags: categories.map{|v| v.values }.flatten.join(','),
        image_url: images.first['600'],
      }.merge(extra_attributes)

      Part.create attributes
    end
end