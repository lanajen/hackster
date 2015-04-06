class Redcarpet::Render::TargetBlankHTML < Redcarpet::Render::HTML
  def initialize(extensions = {})
    super extensions.merge(link_attributes: { target: "_blank" })
  end

  def header(text, header_level)
    text
  end
end