Widget.where(type: 'CodeWidget').update_all(type: 'OldCodeWidget')

CodeRepository.order(:id).each do |f|
  w = CodeRepoWidget.new
  w.widgetable = f.project
  w.name = f.name
  w.url = f.repository
  w.comment = f.comment
  w.save
end

CodeFile.where(type: 'CodeFile').order(:id).each do |file|
  w = CodeWidget.new
  w.widgetable = file.project
  w.name = file.name
  w.raw_code = file.raw_code
  w.language = file.language
  w.comment = file.comment
  w.save
end

Project.where("description is not null and description <> ''").order(:created_at).each do |project|
  parsed = Nokogiri::HTML::DocumentFragment.parse project.description

  parsed.css('.embed-frame').each do |el|
    type = el['data-type']

    case type
    when 'url'
      link = el['data-url']
      next unless link

      embed = Embed.new url: link, fallback_to_default: true

      if embed.schematic_repo?
        w = SchematicWidget.new
        w.widgetable = project
        w.url = link
        w.comment = el['data-caption'].presence
        w.name = embed.provider_name.to_s.capitalize
        w.save
      end
    else
      next
    end
  end
end