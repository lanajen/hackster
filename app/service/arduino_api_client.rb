class ArduinoApiClient
  BASE_API_URL = "https://api.arduino.cc/"
  SKETCH_REGEX = /editor\/([0-9a-zA-Z\-_]+)\/([0-9a-z\-]+)/

  def add_tutorial_url_to_sketch sketch_url, project_url
    url = get_api_url sketch_url

    tutorials = get_tutorials_info url
    tutorials << project_url
    set_tutorials_info url, tutorials
  end

  def initialize user
    auth = user.authorizations.where(provider: 'arduino').order(:created_at).last
    raise "User hasn't logged in with Arduino, can't initialize API client." unless auth
    @token = auth.token
  end

  private
    def extract_uid_and_id_from_sketch_url sketch_url
      sketch_url.match SKETCH_REGEX
      return $1, $2
    end

    def get_api_url sketch_url
      uid, sketch_id = extract_uid_and_id_from_sketch_url sketch_url

      BASE_API_URL + uid + '/sketches/' + sketch_id
    end

    def get_tutorials_info url
      Rails.logger.debug "get_tutorials_info for url: `#{url}` (token: `#{@token}`)"

      resp = open(url,
        'Content-Type' => 'application/json',
        'Authorization' => token_header,
        ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
      ).read
      puts 'get response: ' + resp.inspect

      sketch_info = JSON.parse resp

      sketch_info['tutorials'] || []
    end

    def set_tutorials_info url, tutorials
      request = Net::HTTP::Put.new(url, {
        'Content-Type' => 'application/json',
        'Authorization' => token_header
      })
      request.set_form_data(tutorials)
      response = http.request(request)
      puts 'set response: ' + response.inspect
    end

    def token_header
      "Token #{@token}"
    end

    # rescue OpenURI::HTTPError => e
    #   # 500 error or something alike
    #   AppLogger.new("Failed to get Arduino user_info for `#{user_name}`, token `#{token}`, failed #{failed_count} times",
    #     'http_error',
    #     'arduino',
    #     e).stdout.log

    #   # retry on 500
    #   if e.message =~ /500/ and failed_count < MAX_TRIES
    #     sleep 1
    #     get_user_info user_name, token, failed_count + 1
    #   else
    #     nil
    #   end
    # end


end