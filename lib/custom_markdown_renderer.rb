class Redcarpet::Render::CustomRenderer < Redcarpet::Render::HTML
  include Redcarpet::Render::SociableHTML

  def initialize(extensions = {})
    super extensions.merge(hard_wrap: true, escape_html: true, link_attributes: { target: "_blank" })
  end

  def header(text, header_level)
    text
  end
end

Redcarpet::MARKDOWN_FILTERS = {
  autolink: true,
  no_styles: true,
  no_images: true,
  escape_html: true,
  no_intra_emphasis: true,
  fenced_code_blocks: true,
  space_after_headers: true,
}