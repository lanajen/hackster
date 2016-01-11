class BaseImage < Attachment
  before_save :truncate_title

  def self.versions
    "::#{name}::VERSIONS".constantize
  end

  def imgix_url version=nil, extra_options={}
    return unless file_url
    if BaseUploader.storage == CarrierWave::Storage::File
      file_url
    else
      client = Imgix::Client.new(host: imgix_config[:host], token: imgix_config[:token], secure: true)
      path = file_url.gsub "https://#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com", ''
      if path =~ /\.jpe?g\Z/
        extra_options.merge!({ fm: :jpg })
      end
      opts = opts_for_version(version).merge extra_options
      client.path(path).to_url(opts)
    end
  end

  private
    def imgix_config
      if use_alt
        {
          host: ENV['IMGIX_HOST_ALT'],
          token: ENV['IMGIX_TOKEN_ALT'],
        }
      else
        {
          host: ENV['IMGIX_HOST'],
          token: ENV['IMGIX_TOKEN'],
        }
      end
    end

    def opts_for_version version
      return {} unless version

      raise "Unknown version '#{version}' for '#{self.class.name}'." unless version.to_sym.in? self.class.versions.keys
      self.class.versions[version.to_sym]
    end

    def truncate_title
      self.title = title.truncate 255 if title
    end
end