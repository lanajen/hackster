class Embed
  LINK_REGEXP = {
    /123d\.circuits\.io\/circuits\/([a-z0-9\-]+)/ => "<iframe width='100%' height='100%'
      src='https://123d.circuits.io/circuits/|id|/embed' frameborder='0'
      marginwidth='0' marginheight='0' scrolling='no'></iframe>",
    /bitbucket\.org\/([0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+)/ => 'BitbucketWidget.new(repo:"|href|",name:"Bitbucket repo")',
    /github\.com\/([0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+)/ => 'GithubWidget.new(repo:"|href|",name:"Github repo")',
    /instagram\.com\/p\/([a-zA-Z]+)/ => '<iframe src="//instagram.com/p/|id|/embed/" width="100%" height="100%" frameborder="0" scrolling="no" allowtransparency="true"></iframe>',
    /oshpark\.com\/shared_projects\/([a-zA-Z]+)/ => { embed_class: 'original', code: '<div class="oshpark-widget"><div class="pull-left"><a href="javascript:openLightBox(707,0);"><img alt="Thumb i" src="http://uploads.oshpark.com/uploads/project/top_image/|id|/thumb_i.png"></a><a href="javascript:openLightBox(707,1);"><img alt="Thumb i" src="http://uploads.oshpark.com/uploads/project/bottom_image/|id|/thumb_i.png"></a></div><ul class="list-unstyled pull-right"><li><a class="btn btn-default btn-sm" href="http://oshpark.com/shared_projects/|id|/order" rel="nofollow" target="_blank">Order PCB</a></li><li><a class="btn btn-default btn-sm" href="http://uploads.oshpark.com/uploads/project/design/|id|/design.brd" rel="nofollow">Download BRD file</a></li><li><a class="btn btn-default btn-sm" href="http://oshpark.com/shared_projects/|id|" rel="nofollow" target="_blank">View project on OSH Park</a></li><li class="credits">Via<a href="http://www.oshpark.com" rel="nofollow" target="_blank">OSH Park</a></li></ul><div class="clearfix"></div></div>', },
    /sketchfab\.com\/models\/([a-z0-9]+)/ => '<iframe width="100%" height="100%" frameborder="0" allowFullScreen webkitallowfullscreen mozallowfullscreen src="https://sketchfab.com/models/|id|/embed"></iframe>',
    /tindie\.com/ => 'BuyWidget.new(link:"|href|",name:"Where to buy")',
    /upverter\.com\/[^\/]+\/([a-z0-9]+)\/[^\/]+/ => '<iframe title="" width="100%" height="100%" scrolling="no"
      frameborder="0" name="" class="eda_tool"
      src="https://upverter.com/eda/embed/#designId=|id|,actionId="></iframe>',
    /ustream\.tv\/([a-z]+\/[0-9]+(\/[a-z]+\/[0-9]+)?)/ => '<iframe width="100%" height="100%" src="//www.ustream.tv/embed/|id|?v=3&amp;wmode=direct" scrolling="no" frameborder="0" style="border: 0px none transparent;"></iframe>',
    /vimeo\.com\/([0-9]+)/ => '<iframe src="//player.vimeo.com/video/|id|" width="100%" height="100%" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>',
    /vine\.co\/v\/([a-zA-Z0-9]+)/ => '<iframe class="vine-embed" src="https://vine.co/v/MPHz7z9pjHE/embed/simple" width="100%" height="100%" frameborder="0"></iframe><script async src="//platform.vine.co/static/scripts/embed.js" charset="utf-8"></script>',
    /(?:youtube\.com|youtu\.be)\/(?:watch\?v=|v\/)?([a-zA-Z0-9\-_]+)/ => '<iframe width="100%" height="100%" src="//www.youtube.com/embed/|id|?rel=0" frameborder="0" allowfullscreen></iframe>',
    /(.+\.(?:jpg|jpeg|bmp|gif|png)(?:\?.*)?)$/ => { embed_class: 'original', code: '<div style="background-image:url(|id|)" class="embed-img"></div>',},
    # /(.+\.(html|html|asp|aspx)(\?.*)?)$/ => nil,
    # /(.+\.[a-z]{3,4}(\?.*)?)$/ => { embed_class: 'original', code: '<div class="document-widget"><div class="file"><i class="fa fa-file-o fa-lg"></i><a href="|id|">|id|</a></div></div>',},
  }

  attr_accessor :url, :code

  def self.find_code_for_url url, render_defaults=false
    code = nil
    LINK_REGEXP.each do |regexp, provider_code|
      if url =~ Regexp.new(regexp)
        case provider_code
        when String
          embed_class = 'widescreen'
        when Hash
          embed_class = provider_code[:embed_class]
          provider_code = provider_code[:code]
        end

        code = generate_code url, embed_class, provider_code, $1
        break
      end
    end
    if code.nil? and render_defaults
      if url.match /(.+\/([^\/]+\.[a-z]{3,4})(\?.*)?)$/
        embed_class = 'original'
        provider_code = '<div class="document-widget"><div class="file"><i class="fa fa-file-o fa-lg"></i><a href="|id|">|name|</a></div></div>'
        code = generate_code url, embed_class, provider_code, $1, $2
      end
    end
    code
  end

  def self.generate_code url, embed_class, provider_code, id, name=nil
    code = "<figure contenteditable='false' class='embed #{embed_class}'>"
    provider_code = provider_code.gsub(/\|id\|/, id)
    provider_code = provider_code.gsub(/\|name\|/, name) if name
    code << provider_code
    code << "<figcaption contenteditable='true' data-default-text='Type in a caption' data-disable-toolbar='true'>#{url}</figcaption></figure>"
    code
  end

  def initialize url
    @url = url
    @code = self.class.find_code_for_url @url
  end

  def to_json
    {
      code: code,
      url: url,
    }
  end
end