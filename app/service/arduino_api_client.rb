class ArduinoApiClient
  BASE_API_URL = "https://api-dev.arduino.cc/create/user/"
  SKETCH_REGEX = /editor\/([0-9a-zA-Z\-_]+)\/([0-9a-z\-]+)/

  def add_tutorial_url_to_sketch sketch_url, project_url
    url = get_api_url sketch_url

    if tutorials = get_tutorials_info(url)
      unless project_url.in? tutorials
        tutorials << project_url
        set_tutorials_info url, tutorials
      end
    end
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

      sketch_info = JSON.parse resp

      sketch_info['tutorials'] || []

    # rescue OpenURI::HTTPError => e
    #   # 500 error or something alike
    #   AppLogger.new("Failed to get_tutorials_info for `#{url}`, token `#{token}`: \"#{e.message}\"",
    #     'http_error',
    #     'arduino',
    #     e).stdout.log

    #   if e.message =~ /403/
    #     # unauthorized
    #   elsif e.message =~ /404/
    #     # not found
    #   else
    #     nil
    #   end
    end

    def set_tutorials_info url, tutorials
      Rails.logger.debug "set_tutorials_info for url: `#{url}` with tutorials=`#{tutorials}` (token: `#{@token}`)"

      u = URI.parse url
      http = Net::HTTP.new(u.host, u.port)
      if u.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Put.new(u.request_uri, {
        'Content-Type' => 'application/json',
        'Authorization' => token_header
      })
      body = { tutorials: tutorials }.to_json
      request.body = body

    # rescue OpenURI::HTTPError => e
    #   # 500 error or something alike
    #   AppLogger.new("Failed to get_tutorials_info for `#{url}`, token `#{token}`: \"#{e.message}\"",
    #     'http_error',
    #     'arduino',
    #     e).stdout.log

    #   if e.message =~ /403/
    #     # unauthorized
    #   elsif e.message =~ /404/
    #     # not found
    #   else
    #     nil
    #   end
    end

    def token_header
      "Token #{@token}"
    end
end