Project.where("description is not null and description <> ''").where("id > 6632").order(:created_at).each do |project|
  parsed = Nokogiri::HTML::DocumentFragment.parse project.description

  parsed.css('.embed-frame').each do |el|
    type = el['data-type']

    case type
    when 'url'
      link = el['data-url']
      next unless link

      embed = Embed.new url: link, fallback_to_default: true

      if embed.cad_repo?
        w = CadRepoWidget.new
        w.widgetable = project
        w.url = link
        w.comment = el['data-caption'].presence
        w.name = embed.provider_name.to_s.capitalize
        w.save
      end
    when 'widget'
      widget_id = el['data-widget-id']
      widget = StlWidget.find_by_id widget_id
      if widget
        widget.sketchfab_files.each do |file|
          w = CadFileWidget.new
          w.document = file
          w.name = file.file_name
          w.widgetable = widget.widgetable
          w.comment = el['data-caption'].presence
          w.save
        end
      end
    when 'file'
      file_id = el['data-file-id']
      file = Attachment.find_by_id file_id
      if file
        if file.file_extension.in? SketchfabFile::SKETCHFAB_SUPPORTED_EXTENSIONS
          f = SketchfabFile.new
          f.remote_file_url = file.file_url
          f.save
          w = CadFileWidget.new
          w.document_id = f.id
          w.comment = el['data-caption'].presence
          w.name = f.file_name
          w.widgetable = project
          w.save
        end
      end
    else
      next
    end
  end
end