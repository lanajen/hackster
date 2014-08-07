class WidgetObserver < ActiveRecord::Observer
  # def after_create record
  #   update_project_for record
  # end

  # def after_destroy record
  #   update_project_for record
  # end

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
    when 'credits_widget'
      Cashier.expire "project-#{record.project_id}-metadata"
    end

    record.update_column :properties, record.properties.to_yaml if @save
    expire record
  end

  private
    def expire record
      Cashier.expire "widget-#{record.id}", "project-#{record.project_id}-widgets" if record.widgetable_type == 'Project'
    end

    # def update_project_for record
    #   if record.widgetable_type == 'Project'
    #     record.project.touch
    #     record.project.update_counters only: [:widgets]
    #   end
    # end
end