class ProjectCollectionObserver < ActiveRecord::Observer
  def after_create record
    update_counters record
  end

  def after_destroy record
    update_counters record
  end

  private
    def update_counters record
      record.collectable.update_counters only: [:projects, :external_projects, :private_projects] if record.collectable.class == Tech
    end
end