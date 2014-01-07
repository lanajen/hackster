class UpverterWidget < IframeSchematicsWidget
  def iframe_template
    '<iframe title="|title|" width="420" height="315" scrolling="no"
    frameborder="0" name="|title|" class="eda_tool"
    src="http://upverter.com/eda/embed/#designId=|id|,actionId="></iframe>'
  end

  def link_regexp
    /upverter\.com\/[^\/]+\/([a-z0-9]+)\/([^\/]+)/
  end

  def provider
    'Upverter'
  end
end