class PostObserver < BaseBroadcastObserver
  def after_create record
    super record
    expire_widget record
  end

  def after_save record
    expire_widget record if record.title_changed?
  end

  private
    def expire_widget record
      if record.threadable_type == 'Project' and
        widget = record.threadable.widgets.where(type: widget_type).first
        widget.touch
      end
    end

  private
    def project_id record
      record.threadable_id
    end
end