class ArduinoUser
  BASE_API_URL = "#{ENV['ARDUINO_API_HOST']}/create/user/"

  def initialize data
    @user_name = data.info.id
    @token = data.credentials.token
  end

  def is_beta_tester?
    if user_info = get_user_info(@user_name, @token)
      parsed_info = JSON.parse user_info
      parsed_info.try(:[], 'services').try(:[], 'create').try(:[], 'enabled') == true
    end
  end

  private
    def get_user_info user_name, token
      url = BASE_API_URL + user_name + '?app=create'
      token_header = "Token #{token}"
      resp = open(url,
        'Content-Type' => 'application/json',
        'Authorization' => token_header,
        ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
      ).read

    rescue OpenURI::HTTPError
      # 500 error or something alike
    end
end