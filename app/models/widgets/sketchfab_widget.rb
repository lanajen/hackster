class SketchfabWidget < IframeSchematicsWidget
  def iframe_template
    '<iframe width="420" height="315" frameborder="0" allowFullScreen webkitallowfullscreen mozallowfullscreen src="https://sketchfab.com/models/|id|/embed"></iframe>'
  end

  def link_regexp
    /sketchfab\.com\/models\/([a-z0-9]+)/
  end

  def provider
    'Sketchfab'
  end
end