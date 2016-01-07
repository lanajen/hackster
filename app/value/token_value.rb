class TokenValue
  def initialize model, token
    @model = model
    @token = find_token token
  end

  def to_s
    @token
  end

  private
    def find_token token
      attribute = token.split(/:/)[0]
      modifier = (token.match(/:/) ? token.split(/:/)[1].to_sym : nil)
      if @model.respond_to? attribute
        value = @model.send(attribute)
        case value
        when DateTime, Time, Date
          value = "#{I18n.l(value.in_time_zone(PDT_TIME_ZONE), format: modifier)} PT"
        when NilClass
          value = "[\"#{token}\" is not set]"
        end
        value
      else
        raise UnknownToken, "Unrecognized token `#{token}`"
      end
    end
end

class UnknownToken < StandardError; end