class SparkfunWishlist
  BASE_URL = 'https://www.sparkfun.com/wish_lists'

  def fetch
    if sparkfun_json
      sparkfun_json['items'].keys.each do |mpn|
        product_id = mpn.gsub /\A[A-Z]+\-0*/, ''
        parts << SparkfunPart.new(product_id)
      end
    end
  end

  def initialize id
    @id = id
    fetch
  end

  def json_url
    "#{url}.json"
  end

  def parts
    @parts ||= []
  end

  def sparkfun_json
    return @sparkfun_json if @sparkfun_json

    response = open(json_url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
    @sparkfun_json = JSON.parse response
  rescue => e
    puts "Failed opening #{json_url}."
  end

  def url
    "#{BASE_URL}/#{@id}"
  end
end