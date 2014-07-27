class WidgetObserver < ActiveRecord::Observer
  def after_create record
    update_project_for record
    expire record
  end

  def after_destroy record
    update_project_for record
  end

  def after_save record
    case record.identifier
    when 'document_widget'
      record.documents_count = record.documents.count
      @save = true
    when 'image_widget'
      record.images_count = record.images.count
      @save = true
    when 'part_widget'
      record.parts_count = record.parts.count
      @save = true
    end

    record.project.update_attributes description_edited_at: Time.now
    record.update_column :properties, record.properties.to_yaml if @save
  end

  def before_update record
    expire record
  end

  private
    def expire record
      Cashier.expire "widget-#{record.id}", "project-#{record.project_id}-widgets"
    end

    def update_project_for record
      record.project.touch
      record.project.update_counters only: [:widgets]
    end
end