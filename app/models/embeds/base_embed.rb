class BaseEmbed
  attr_accessor :id

  def format
    nil
  end

  def identifier
    self.class.name.to_s.underscore.gsub(/_embed/, '')
  end

  def initialize id
    @id = id
  end

  def type
    'url'
  end
end