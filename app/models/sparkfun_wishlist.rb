class SparkfunWishlist < SparkfunResource
  RESOURCE_ENDPOINT = '/wish_lists'

  attr_reader :description, :name

  def fetch
    if sparkfun_json
      sparkfun_json['items'].each do |mpn, values|
        product_id = mpn.gsub /\A[A-Z]+\-0*/, ''
        parts[SparkfunPart.new(product_id)] = values['quantity']
      end
      @description = sparkfun_json['description']
      @name = sparkfun_json['name']
    end
  end

  def initialize id
    @id = id
    fetch
  end

  def hackster_parts
    parts.keys.map{|p| p.hackster_part }
  end

  def has_parts?
    parts.any?
  end

  def parts
    @parts ||= {}
  end
end