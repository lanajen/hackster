class WidgetObserver < ActiveRecord::Observer
  def after_create record
    update_completion_rate_for record unless record.completion_rate.zero? or record.completion_share.zero?
  end

  def after_destroy record
    update_completion_rate_for record
  end

  def after_update record
    update_completion_rate_for record if record.completion_rate_changed? or record.completion_share_changed?
  end

  private
    def update_completion_rate_for record
      record.stage.update_completion_rate!
    end
end