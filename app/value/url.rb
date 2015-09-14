require 'addressable/uri'

class Url
  def == another_url
    to_s == another_url.to_s
  end

  def initialize url
    @url = case url
    when Url
      url.to_s
    when String
      @url = url
      if @url.present?
        @url = 'http://' + @url unless @url =~ /\A(http|git)/
      end
      @url
    else
      nil
    end
  end

  def present?
    @url.present?
  end

  def to_s
    @url.to_s
  end

  def valid?
    !!Addressable::URI.parse(@url)
  rescue Addressable::URI::InvalidURIError
    false
  end
end