Project.where("description is not null and description <> ''").order(:created_at).each do |project|
  parsed = Nokogiri::HTML::DocumentFragment.parse project.description

  parsed.css('.embed-frame').each do |el|
    type = el['data-type']

    case type
    when 'url'
      link = el['data-url']
      next unless link

      embed = Embed.new url: link, fallback_to_default: true

      if embed.provider_name.to_s.in? %w(gist github snip2code bitbucket codebender)
        file = project.code_files.new
        file.repository = link
        file.comment = el['data-caption'].presence
        file.name = embed.provider_name.to_s.capitalize
        file.save
      end
    when 'widget'
      widget_id = el['data-widget-id']
      widget = CodeWidget.find_by_id widget_id
      if widget
        file = CodeFile.new
        file.project_id = widget.project_id
        file.raw_code = widget.raw_code.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '') if widget.raw_code.present?
        # file.document = widget.document
        file.comment = el['data-caption'].presence
        file.name = widget.file_name
        file.language = widget.language
        file.save
      end
    else
      next
    end
  end
end