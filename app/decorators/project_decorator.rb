class ProjectDecorator < ApplicationDecorator
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
    /(youtube\.com|youtu\.be)\/(watch\?v=|v\/)?([a-zA-Z0-9-_]+)/ => '<iframe width="100%" height="100%" src="//www.youtube.com/embed/|id|?rel=0" frameborder="0" allowfullscreen></iframe>',
  }

  def cover_image version=:cover
    if model.cover_image and model.cover_image.file_url
      model.cover_image.file_url(version)
    else
      h.asset_url "project_default_#{version}_image.png"
    end
  end

  def description
    if model.description.present?
      parsed = Nokogiri::HTML::DocumentFragment.parse model.description

      parsed.css('.embed-frame').each do |el|
        link = el['data-embed']
        code = Embed.new(link).code
        if caption = el['data-caption']
          code = Nokogiri::HTML::DocumentFragment.parse code
          figcaption = code.at_css('figcaption')
          figcaption.content = caption
          code = code.to_html
        end
        el.add_child code if code
      end
      parsed.to_html.html_safe
    else
      ""
    end
  end

  def logo size=nil, use_default=true
    if model.logo and model.logo.file_url
      model.logo.file_url(size)
    elsif use_default
      width = case size
      when :tiny
        20
      when :mini
        40
      when :thumb
        60
      when :medium
        80
      when :big
        200
      end
      "project_default_logo_#{width}.png"
    end
  end

  def logo_link size=:thumb
    link_to_model h.image_tag(logo(size), alt: model.name, class: 'img-responsive')
  end

  def logo_or_placeholder
    if model.logo and model.logo.file
      h.image_tag logo(:big), class: 'img-circle project-logo'
    else
      h.content_tag(:div, '', class: 'logo-placeholder')
    end
  end
end
