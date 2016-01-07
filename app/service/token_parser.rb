class TokenParser
  CLEANUP_REGEXP = /[\{\}]/
  LOOKUP_REGEXP = /\{\{[a-z_:]+\}\}/

  def all
    @all ||= find_all
  end

  def all_cleaned
    @all_cleaned ||= all.map{|t| cleanup_token(t) }
  end

  def initialize model, text, opts={}
    @model = model
    @text = text
    @regexp = opts[:regexp].present? ? Regexp.new(opts[:regexp]) : LOOKUP_REGEXP
    @cleanup_regexp = opts[:cleanup_regexp].present? ? Regexp.new(opts[:cleanup_regexp]) : CLEANUP_REGEXP
  end

  def replace
    find_all.each do |token|
      token_name = cleanup_token(token)
      if substitute = get_value_for_token(token_name)
        @text.gsub!(token, substitute.to_s) if substitute
      end
    end
    @text
  end

  private
    def cleanup_token token
      token.gsub @cleanup_regexp, ''
    end

    def find_all
      @text ? @text.scan(@regexp) : []
    end

    def get_value_for_token token
      TokenValue.new(@model, token).to_s
    rescue UnknownToken
      nil
    end
end