class BuildLogDecorator < ApplicationDecorator
  include MediumEditorDecorator
  delegate :current_page, :total_pages, :limit_value

  def body
    parse_medium model.body
  end

  def title_not_default
    model.title == BuildLog::DEFAULT_TITLE ? nil : model.title
  end
end
