class MarkdownFilter
  def initialize string
    @string = string
  end

  def to_html
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer, {
      no_intra_emphasis: true,
      tables: true,
      fenced_code_blocks: true,
      autolink: true,
      disable_indented_code_blocks: true,
      lax_spacing: true,
      underline: true,
    })
    html = markdown.render @string
    # toc filter: https://github.com/jch/html-pipeline/blob/master/lib/html/pipeline/toc_filter.rb
    # reverse: https://github.com/xijo/reverse_markdown
    # md editor: https://code.google.com/p/pagedown/source/browse/Markdown.Editor.js
    # stackedit: https://github.com/benweet/stackedit
    # dilinger: https://github.com/joemccann/dillinger
    # vues: http://vuejs.org/guide/custom-filter.html

    sanitized_text = Sanitize.clean(html, Sanitize::Config::HACKSTER)

    sanitized_text
  end
end