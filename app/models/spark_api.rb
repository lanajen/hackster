module SparkApi

  class Device
    attr_accessor :device_id

    def initialize device_id
      @device_id = device_id
    end

    def flash
    end
  end

  class Client
    ENDPOINT = 'https://api.spark.io/v1'

    attr_accessor :auth_token

    def initialize auth_token
      @auth_token = auth_token
      @headers = ["Authorization: Bearer #{@auth_token}"]
    end
  end
end