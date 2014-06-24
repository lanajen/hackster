class GroupRelationObserver < ActiveRecord::Observer
  def after_create record
    update_counters record
  end

  def after_destroy record
    update_counters record
  end

  private
    def update_counters record
      record.group.update_counters only: [:projects, :external_projects, :private_projects]
    end
end