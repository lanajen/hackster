class FileNameGenerator
  def initialize *phrase
    @phrase = phrase.join(' ')
  end

  def to_s
    return @file_name if @file_name

    @file_name = @phrase.strip.downcase
    @file_name.gsub! /\s/, '_'
    @file_name.gsub! /[^a-zA-Z0-9_-]/, ''
    @file_name += "_#{Time.now.strftime '%y%m%d%H%M%S'}"
    @file_name
  end
end