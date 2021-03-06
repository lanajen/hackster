class Embed
  DEFAULT_FORMAT = 'widescreen'
  LINK_REGEXP = {
    /123d\.circuits\.io\/circuits\/([a-z0-9\-]+)/ => :circuitsio,
    /bitbucket\.org\/([0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+)/ => :bitbucket,
    /channel9\.msdn\.com\/([0-9a-zA-Z_\-\/]+)/ => :channel9,
    /codebender\.cc\/((?:sketch:|example\/)[0-9a-zA-Z\/:]+)/ => :codebender,
    /create(?:\-dev)?\.arduino\.cc\/editor\/([0-9a-zA-Z\-\_]+\/[0-9a-z\-]+)/ => :arduino,
    /digikey.com\/schemeit\/(?:embed\/)?(#[0-9a-zA-Z]+)/ => :schemeit,
    /gist\.github\.com\/(?:[0-9a-zA-Z_\-]+\/)?([0-9a-zA-Z_\-]+)/ => :gist,
    /github\.com\/(?:downloads\/)?([0-9a-zA-Z_\-\.]+\/[0-9a-zA-Z_\-\.]+)/ => :github,
    /fritzing\.org\/projects\/([0-9a-z-]+)/ => :fritzing,
    /instagram\.com\/p\/([a-zA-Z\-0-9]+)/ => :instagram,
    /kickstarter\.com\/projects\/([0-9a-z\-]+\/[0-9a-z\-]+)/ => :kickstarter,
    /myhub\.autodesk360\.com\/([a-z0-9]+\/shares\/public\/[a-zA-Z0-9]+)/ => :autodesk360,
    /oshpark\.com\/shared_projects\/([a-zA-Z0-9]+)/ => :oshpark,
    /sketchfab\.com\/models\/([a-z0-9]+)/ => :sketchfab,
    /snip2code\.com\/Snippet\/([0-9]+\/[0-9a-zA-Z]+)/ => :snip2code,
    /thingiverse\.com\/thing\:([0-9]+)/ => :thingiverse,
    /twitter.com\/([a-zA-Z0-9_@]+\/status\/[0-9]+)/ => :twitter,
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

  attr_reader :provider_name, :provider_id, :provider, :widget, :type, :url, :default_caption, :images

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
    provider and provider_name.to_s.in? %w(autodesk360 github sketchfab thingiverse youmagine)
  end

  def code_repo?
    provider and provider_name.to_s.in? %w(arduino bitbucket codebender gist github snip2code)
  end

  def for_text_editor?
    provider and provider_name.to_s.in? %w(instagram kickstarter ustream vimeo vine youtube image mp4 channel9 twitter)
  end

  def schematic_repo?
    provider and provider_name.to_s.in? %w(circuitsio oshpark upverter fritzing github schemeit)
  end

  def hid
    @hid ||= SecureRandom.hex(10)
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
        @default_caption = options[:default_caption] || @url
        @type = @provider.type
      end
    elsif @widget_id = options[:widget_id]
      if @widget = Widget.find_by_id(@widget_id)
        @provider_name = @widget.identifier
        @type = 'widget'
        @format = @widget.embed_format || 'original'
      end
    elsif @widget = options[:widget]
      @provider_name = @widget.identifier
      @type = 'widget'
      @format = @widget.embed_format || 'original'
      if @widget.type == 'ImageWidget'
        @images = if options[:images]
          options[:images].select{|i| i.attachable_type == 'Widget' and i.attachable_id == @widget.id }
        else
          widget.images
        end
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