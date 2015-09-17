class SparkfunPart
  BASE_URL = 'https://www.sparkfun.com/products'

  def fetch
    if sparkfun_json
      sparkfun_json.each do |key, val|
        self.class.define_method key do
          instance_variable_get "@#{key}"
        end
        instance_variable_set "@#{key}", val
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