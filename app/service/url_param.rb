class UrlParam
  def add_param param_name, param_value
    new_param = [param_name, param_value]
    params = @uri.query ? (URI.decode_www_form(@uri.query) << new_param) : [new_param]
    @uri.query = URI.encode_www_form(params)
    to_s
  end

  def initialize url
    @uri = URI url
  end

  def remove_params param_names
    if @uri.query
      params = Hash[URI.decode_www_form(@uri.query)]
      param_names.each do |param_name|
        params.delete(param_name)
      end
      @uri.query = URI.encode_www_form(params.to_a)
      @uri.query = nil if @uri.query.blank?
    end
    to_s
  end

  def to_s
    @uri.to_s
  end
end