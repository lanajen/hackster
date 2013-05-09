class FileResolver
  def self.read_file file_name
    File.read file_name
  rescue => e
    case e
    when Errno::ENOENT
      Rails.logger.debug "Couldn't find file '#{file_name}'."
    else
      raise e
    end
    false
  end
end