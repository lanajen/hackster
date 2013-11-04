class WidgetObserver < ActiveRecord::Observer
  def after_create record
    # update_completion_rate_for record unless record.completion_rate.zero? or record.completion_share.zero?
    update_project_for record
  end

  def after_destroy record
    # update_completion_rate_for record
    update_project_for record
  end

  def after_update record
    # update_completion_rate_for record if record.completion_rate_changed? or record.completion_share_changed?
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

    record.update_column :properties, record.properties.to_yaml if @save
  end

  private
    def update_completion_rate_for record
      record.stage.update_completion_rate! if record.stage
    end

    def update_project_for record
      record.project.touch
      record.project.update_counters only: [:widgets]
    end
end