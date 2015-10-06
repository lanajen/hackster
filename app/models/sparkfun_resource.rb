class SparkfunResource
  BASE_URL = 'https://www.sparkfun.com'
  RESOURCE_ENDPOINT = ''

  def json_url
    "#{url}.json"
  end

  def resource_endpoint
    self.class::RESOURCE_ENDPOINT
  end

  def sparkfun_json
    return @sparkfun_json if @sparkfun_json

    puts "Fetching #{json_url}..."
    response = open(json_url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
    @sparkfun_json = JSON.parse response
  rescue => e
    puts "Failed opening \"#{json_url}\": #{e.message}."
  end

  def url
    "#{BASE_URL}#{resource_endpoint}/#{@id}"
  end
end