class TwitterHandle
  def initialize url
    @url = url

    if @url.present?
      handle = @url.match(/twitter.com\/([a-zA-Z0-9_]+)/).try(:[], 1)
      @handle = handle.present? ? "@#{handle}" : nil
    end
  end

  def handle
    @handle
  end

  def present?
    @handle.present?
  end

  def to_s
    @handle.to_s
  end
end