class ArduinoUser
  BASE_API_URL = "#{ENV['ARDUINO_API_HOST']}/create/user/"

  def initialize data
    @user_name = data.uid
    @token = data.credentials.token
  end

  def is_beta_tester?
    if user_info = get_user_info(@user_name, @token)
      parsed_info = JSON.parse user_info
      Rails.logger.debug "Arduino user_info: #{parsed_info.inspect}"

      if parsed_info.try(:[], 'services').try(:[], 'create').try(:[], 'enabled') == true
        true
      else
        AppLogger.new("Arduino user `#{user_name}` appears unauthorized: #{parsed_info.inspect}",
          'unauthorized',
          'arduino').log
        false
      end
    end
  end

  private
    def get_user_info user_name, token
      Rails.logger.debug "Fetching Arduino user_info for `#{user_name}` (token: `#{token}`)"

      url = BASE_API_URL + user_name + '?app=create'
      token_header = "Token #{token}"
      resp = open(url,
        'Content-Type' => 'application/json',
        'Authorization' => token_header,
        ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
      ).read

    rescue OpenURI::HTTPError => e
      # 500 error or something alike
      AppLogger.new("Failed to get Arduino user_info for `#{user_name}`",
        'http_error',
        'arduino',
        e).log.stdout

      nil
    end
end