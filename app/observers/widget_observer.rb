class WidgetObserver < ActiveRecord::Observer
  def after_destroy record
    expire record
  end

  def after_save record
    expire record
  end

  alias_method :after_touch, :after_save

  private
    def expire record
      keys = []
      if record.widgetable_type == 'BaseArticle'
        case record.type
        when 'CadRepoWidget', 'CadFileWidget'
          keys << "project-#{record.project_id}-cad"
        when 'SchematicWidget', 'SchematicFileWidget'
          keys << "project-#{record.project_id}-schematics"
        when 'CodeWidget', 'CodeRepoWidget'
          keys << "project-#{record.project_id}-code"
        when 'PartsWidget'
          keys << "project-#{record.project_id}-components"
        when 'CreditsWidget'
          keys << "project-#{record.project_id}-credits"
        else
          keys << "project-#{record.project_id}-widgets"
        end
        keys += ["project-#{record.project_id}-attachments", "project-#{record.project_id}-left-column", "project-#{record.project_id}"]
      end
      if keys.any?
        Cashier.expire *keys
        record.widgetable.try(:purge)
      end
    end
end