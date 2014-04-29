class CircuitsioWidget < IframeSchematicsWidget
  def iframe_template
    "<iframe width='420' height='260'
    src='https://123d.circuits.io/circuits/|id|/embed' frameborder='0'
    marginwidth='0' marginheight='0' scrolling='no'></iframe>"
  end

  def link_regexp
    /123d\.circuits\.io\/circuits\/([a-z0-9\-]+)/
  end

  def provider
    'Circuits.io'
  end
end