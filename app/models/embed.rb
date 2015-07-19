class Embed
  DEFAULT_FORMAT = 'widescreen'
  LINK_REGEXP = {
    /123d\.circuits\.io\/circuits\/([a-z0-9\-]+)/ => :circuitsio,
    /bitbucket\.org\/([0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+)/ => :bitbucket,
    /codebender\.cc\/sketch:([0-9]+)/ => :codebender,
    /gist\.github\.com\/(?:[0-9a-zA-Z_\-]+\/)?([0-9a-zA-Z_\-]+)/ => :gist,
    /github\.com\/(?:downloads\/)?([0-9a-zA-Z_\-\.]+\/[0-9a-zA-Z_\-\.]+)/ => :github,
    /fritzing\.org\/projects\/([0-9a-z-]+)/ => :fritzing,
    /instagram\.com\/p\/([a-zA-Z\-0-9]+)/ => :instagram,
    /kickstarter\.com\/projects\/([0-9a-z\-]+\/[0-9a-z\-]+)/ => :kickstarter,
    /myhub\.autodesk360\.com\/([a-z0-9]+\/shares\/public\/[a-zA-Z0-9]+)/ => :autodesk360,
    /oshpark\.com\/shared_projects\/([a-zA-Z0-9]+)/ => :oshpark,
    /sketchfab\.com\/models\/([a-z0-9]+)/ => :sketchfab,
    /snip2code\.com\/Snippet\/([0-9]+\/[0-9a-zA-Z]+)/ => :snip2code,
    /upverter\.com\/[^\/]+\/(?:embed\/)?(?:\#designId\=)?([a-z0-9]+)(?:\/)?(?:[^\/])*/ => :upverter,
    /ustream\.tv\/([a-z]+\/[0-9]+(\/[a-z]+\/[0-9]+)?)/ => :ustream,
    /(?:player\.)?vimeo\.com\/(?:video\/)?([0-9]+)/ => :vimeo,
    /vine\.co\/v\/([a-zA-Z0-9]+)/ => :vine,
    /(?:youtube\.com|youtu\.be)\/(?:watch\?v=|v\/|embed\/)?([a-zA-Z0-9\-_]+)/ => :youtube,
    /youmagine\.com\/designs\/([a-zA-Z0-9\-]+)/ => :youmagine,
    /(.+\.(?:jpg|jpeg|bmp|gif|png)(?:\?.*)?)$/i => :image,
    /(.+\.(?:mp4)(?:\?.*)?)$/i => :mp4,
    # /(.+\.(html|html|asp|aspx|php|js|css)(\?.*)?)$/ => nil,
    # /(.+\.[a-z]{3,4}(\?.*)?)$/ => { embed_class: 'original', code: '<div class="document-widget"><div class="file"><i class="fa fa-file-o fa-lg"></i><a href="|id|">|id|</a></div></div>',},
  }

  attr_reader :provider_name, :provider_id, :provider, :widget, :type, :url, :default_caption

  def self.find_provider_for_url url, fallback_to_default=false
    provider = nil
    LINK_REGEXP.each do |regexp, provider_name|
      if url =~ Regexp.new(regexp)
        klass = "#{provider_name.to_s.camelize}Embed".constantize
        provider = klass.new $1
        break
      end
    end

    if provider.nil? and fallback_to_default
      if url.match /(.+\/([^\/]+\.[a-z]{3,4})(\?.*)?)$/
        provider = DocumentEmbed.new $1
      end
    end
    provider
  end

  def cad_repo?
    provider and provider_name.to_s.in? %w(autodesk360 sketchfab youmagine github)
  end

  def code_repo?
    provider and provider_name.to_s.in? %w(bitbucket codebender gist github snip2code)
  end

  def for_text_editor?
    provider and provider_name.to_s.in? %w(instagram kickstarter ustream vimeo vine youtube image mp4)
  end

  def schematic_repo?
    provider and provider_name.to_s.in? %w(circuitsio oshpark upverter fritzing github)
  end

  def format
    @format || DEFAULT_FORMAT
  end

  def initialize options
    if @url = options[:url]
      if @provider = self.class.find_provider_for_url(@url, options[:fallback_to_default])
        @format = @provider.format
        @provider_id = @provider.id
        @provider_name = @provider.identifier
        @default_caption = @url
        @type = @provider.type
      end
    elsif @widget_id = options[:widget_id]
      if @widget = Widget.find_by_id(@widget_id)
        @provider_name = @widget.identifier
        @type = 'widget'
        @format = @widget.embed_format || 'original'
      end
    elsif file_id = options[:file_id]
      if file = Attachment.find_by_id(file_id)
        @url = file.file_url
        @provider = DocumentEmbed.new @url
        @format = @provider.format
        @provider_id = @provider.id
        @type = @provider.type
        @provider_name = @provider.identifier
        @default_caption = file.title.presence || file.caption
      end
    elsif video_id = options[:video_id]
      if file = Attachment.find_by_id(video_id)
        @url = file.file_url
        @provider = Mp4Embed.new @url
        @format = @provider.format
        @provider_id = @provider.id
        @type = @provider.type
        @provider_name = @provider.identifier
      end
    end
  end

  def to_json
    {
      provider: provider_name,
      url: url,
    }
  end
end