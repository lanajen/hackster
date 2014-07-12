class Embed
  LINK_REGEXP = {
    /123d\.circuits\.io\/circuits\/([a-z0-9\-]+)/ => "<iframe width='100%' height='100%'
      src='https://123d.circuits.io/circuits/|id|/embed' frameborder='0'
      marginwidth='0' marginheight='0' scrolling='no'></iframe>",
    /bitbucket\.org\/([0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+)/ => 'BitbucketWidget.new(repo:"|href|",name:"Bitbucket repo")',
    /github\.com\/([0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+)/ => 'GithubWidget.new(repo:"|href|",name:"Github repo")',
    /instagram\.com\/p\/([a-zA-Z]+)/ => '<iframe src="//instagram.com/p/|id|/embed/" width="100%" height="100%" frameborder="0" scrolling="no" allowtransparency="true"></iframe>',
    /oshpark\.com\/shared_projects/ => 'OshparkWidget.new(link:"|href|",name:"PCB on OSH Park")',
    /sketchfab\.com\/models\/([a-z0-9]+)/ => '<iframe width="100%" height="100%" frameborder="0" allowFullScreen webkitallowfullscreen mozallowfullscreen src="https://sketchfab.com/models/|id|/embed"></iframe>',
    /tindie\.com/ => 'BuyWidget.new(link:"|href|",name:"Where to buy")',
    /upverter\.com\/[^\/]+\/([a-z0-9]+)\/[^\/]+/ => '<iframe title="" width="100%" height="100%" scrolling="no"
      frameborder="0" name="" class="eda_tool"
      src="https://upverter.com/eda/embed/#designId=|id|,actionId="></iframe>',
    /ustream\.tv\/([a-z]+\/[0-9]+(\/[a-z]+\/[0-9]+)?)/ => '<iframe width="100%" height="100%" src="//www.ustream.tv/embed/|id|?v=3&amp;wmode=direct" scrolling="no" frameborder="0" style="border: 0px none transparent;"></iframe>',
    /vimeo\.com\/([0-9]+)/ => '<iframe src="//player.vimeo.com/video/|id|" width="100%" height="100%" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>',
    /vine\.co\/v\/([a-zA-Z0-9]+)/ => '<iframe class="vine-embed" src="https://vine.co/v/MPHz7z9pjHE/embed/simple" width="100%" height="100%" frameborder="0"></iframe><script async src="//platform.vine.co/static/scripts/embed.js" charset="utf-8"></script>',
    /(youtube\.com|youtu\.be)\/(watch\?v=|v\/)?([a-zA-Z0-9\-_]+)/ => '<iframe width="100%" height="100%" src="//www.youtube.com/embed/|id|?rel=0" frameborder="0" allowfullscreen></iframe>',
  }

  attr_accessor :url, :code

  def self.find_code_for_url url
    code = nil
    LINK_REGEXP.each do |regexp, provider_code|
      if url =~ Regexp.new(regexp)
        id = $4 || $3 || $2 || $1  # the last matching element
        code = "<figure contenteditable='false' class='embed widescreen'>"
        code << provider_code.gsub(/\|id\|/, id)
        code << "<figcaption contenteditable='true' placeholder='Type in to add a caption'></figcaption></figure>"
        break
      end
    end
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