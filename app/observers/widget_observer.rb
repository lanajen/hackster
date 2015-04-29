class WidgetObserver < ActiveRecord::Observer
  def after_destroy record
    expire record
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
    # when 'credits_widget'
    #   Cashier.expire "project-#{record.project_id}-metadata"
    end

    record.update_column :properties, record.properties.to_yaml if @save
    expire record
  end

  private
    def expire record
      keys = []
      if record.widgetable_type == 'Project'
        case record.type
        when 'CadRepoWidget', 'CadFileWidget'
          keys << "project-#{record.project_id}-cad"
        when 'SchematicWidget', 'SchematicFileWidget'
          keys << "project-#{record.project_id}-schematics"
        when 'CodeWidget', 'CodeRepoWidget'
          keys << "project-#{record.project_id}-code"
        when 'PartsWidget'
          keys << "project-#{record.project_id}-components"
        else
          keys << "project-#{record.project_id}-widgets"
        end
        keys << "widget-#{record.id}"
        record.widgetable.purge
      end
      Cashier.expire *keys if keys
    end
end