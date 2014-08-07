class Embed
  DEFAULT_FORMAT = 'widescreen'
  LINK_REGEXP = {
    /123d\.circuits\.io\/circuits\/([a-z0-9\-]+)/ => :circuitsio,
    /bitbucket\.org\/([0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+)/ => :bitbucket,
    /gist\.github\.com\/[0-9a-zA-Z_\-]+\/([0-9a-zA-Z_\-]+)/ => :gist,
    /github\.com\/([0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+)/ => :github,
    /instagram\.com\/p\/([a-zA-Z]+)/ => :instagram,
    /oshpark\.com\/shared_projects\/([a-zA-Z]+)/ => :oshpark,
    /sketchfab\.com\/models\/([a-z0-9]+)/ => :sketchfab,
    # /tindie\.com/ => 'BuyWidget.new(link:"|href|",name:"Where to buy")',
    /upverter\.com\/[^\/]+\/([a-z0-9]+)\/[^\/]+/ => :upverter,
    /ustream\.tv\/([a-z]+\/[0-9]+(\/[a-z]+\/[0-9]+)?)/ => :ustream,
    /vimeo\.com\/([0-9]+)/ => :vimeo,
    /vine\.co\/v\/([a-zA-Z0-9]+)/ => :vine,
    /(?:youtube\.com|youtu\.be)\/(?:watch\?v=|v\/)?([a-zA-Z0-9\-_]+)/ => :youtube,
    /(.+\.(?:jpg|jpeg|bmp|gif|png)(?:\?.*)?)$/i => :image,
    # /(.+\.(html|html|asp|aspx|php|js|css)(\?.*)?)$/ => nil,
    # /(.+\.[a-z]{3,4}(\?.*)?)$/ => { embed_class: 'original', code: '<div class="document-widget"><div class="file"><i class="fa fa-file-o fa-lg"></i><a href="|id|">|id|</a></div></div>',},
  }

  attr_reader :provider_name, :provider_id, :provider, :widget, :type, :url

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

  def format
    @format || DEFAULT_FORMAT
  end

  def initialize options
    if @url = options[:url]
      if @provider = self.class.find_provider_for_url(@url, options[:fallback_to_default])
        @format = @provider.format
        @provider_id = @provider.id
        @provider_name = @provider.identifier
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
      end
    # elsif type = options[:new_widget]
    #   @widget = Widget.create type: type, project_id: options[:project_id]
    #   if type == 'PartsWidget'
    #     @widget.parts.create quantity: 1
    #   end
    #   @provider_name = @widget.identifier
    #   @type = 'widget'
    #   @format = 'original'
    end
  end

  def to_json
    {
      provider: provider_name,
      url: url,
    }
  end
end