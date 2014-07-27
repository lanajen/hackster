require 'open-uri'
SKETCHFAB_API_URL = 'https://api.sketchfab.com/v2'
SKETCHFAB_API_MODEL_ENDPOINT = SKETCHFAB_API_URL + '/models'
SKETCHFAB_API_TOKEN = 'f6f4db3865a945a38f0d09cae381efd6'

class SketchfabFile
  def initialize file_url
    @file_url = file_url
    @file = File.open @file_url
  end

  def upload
    response = RestClient.post SKETCHFAB_API_MODEL_ENDPOINT, 'modelFile' => @file, 'token' => SKETCHFAB_API_TOKEN
    puts response.inspect
  end
end