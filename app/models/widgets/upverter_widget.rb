class UpverterWidget < IframeSchematicsWidget
  def iframe_template
    '<iframe title="|title|" width="100%" height="100%" scrolling="no"
    frameborder="0" name="|title|" class="eda_tool"
    src="https://upverter.com/eda/embed/#designId=|id|,actionId="></iframe>'
  end

  def link_regexp
    /upverter\.com\/[^\/]+\/([a-z0-9]+)\/([^\/]+)/
  end

  def provider
    'Upverter'
  end
end