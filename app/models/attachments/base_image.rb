class BaseImage < Attachment
  before_save :truncate_title

  def self.versions
    "::#{name}::VERSIONS".constantize
  end

  def imgix_url version=nil, extra_options={}
    return unless file_url
    client = Imgix::Client.new(host: ENV['IMGIX_HOST'], token: ENV['IMGIX_TOKEN'], secure: true)
    path = file_url.gsub "https://#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com", ''
    opts = opts_for_version(version).merge extra_options
    client.path(path).to_url(opts)
  end

  private
    def opts_for_version version
      return {} unless version

      raise "Unknown version '#{version}' for '#{self.class.name}'." unless version.to_sym.in? self.class.versions.keys
      self.class.versions[version.to_sym]
    end

    def truncate_title
      self.title = title.truncate 255 if title
    end
end